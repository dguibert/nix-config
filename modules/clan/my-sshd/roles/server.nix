{
  config,
  pkgs,
  lib,
  ...
}:
let
  stringSet = list: builtins.attrNames (builtins.groupBy lib.id list);

  domains = stringSet config.clan.my-sshd.certificate.searchDomains;
  realms = stringSet config.clan.my-sshd.certificate.realms;

  cfg = config.clan.my-sshd;
in
{
  imports = [ ../shared.nix ];
  options = {
    clan.my-sshd.hostKeys.rsa.enable = lib.mkEnableOption "Generate RSA host key";
  };
  config = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;

      settings.HostCertificate = lib.mkIf (
        (cfg.certificate.searchDomains != [ ] || cfg.certificate.allowEmptyDomain)
      ) config.clan.core.vars.generators.my-openssh-cert.files."ssh.id_ed25519-cert.pub".path;

      hostKeys = [
        {
          path = config.clan.core.vars.generators.my-openssh.files."ssh.id_ed25519".path;
          type = "ed25519";
        }
      ]
      ++ lib.optional cfg.hostKeys.rsa.enable {
        path = config.clan.core.vars.generators.my-openssh-rsa.files."ssh.id_rsa".path;
        type = "rsa";
      };
    };

    clan.core.vars.generators.my-openssh = {
      files."ssh.id_ed25519" = { };
      files."ssh.id_ed25519.pub".secret = false;
      migrateFact = "openssh";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.openssh
      ];
      script = ''
        ssh-keygen -t ed25519 -N "" -f $out/ssh.id_ed25519
      '';
    };

    programs.ssh.knownHosts.clan-my-sshd-self-ed25519 = {
      hostNames = [
        "localhost"
        config.networking.hostName
      ]
      ++ (lib.optional (config.networking.domain != null) config.networking.fqdn);
      publicKey = config.clan.core.vars.generators.my-openssh.files."ssh.id_ed25519.pub".value;
    };

    clan.core.vars.generators.my-openssh-rsa = lib.mkIf config.clan.my-sshd.hostKeys.rsa.enable {
      files."ssh.id_rsa" = { };
      files."ssh.id_rsa.pub".secret = false;
      runtimeInputs = [
        pkgs.coreutils
        pkgs.openssh
      ];
      script = ''
        ssh-keygen -t rsa -b 4096 -N "" -f $out/ssh.id_rsa
      '';
    };

    clan.core.vars.generators.my-openssh-cert = lib.mkIf (cfg.certificate.searchDomains != [ ]) {
      files."ssh.id_ed25519-cert.pub".secret = false;
      dependencies = [
        "my-openssh"
        "my-openssh-ca"
      ];
      validation = {
        name = config.clan.core.settings.machine.name;
        domains = lib.genAttrs config.clan.my-sshd.certificate.searchDomains lib.id;
      };
      runtimeInputs = [
        pkgs.openssh
        pkgs.jq
      ];
      script = ''
        ssh-keygen \
          -s $in/my-openssh-ca/id_ed25519 \
          -I ${config.clan.core.settings.machine.name} \
          -h \
          -n ${
            lib.concatStringsSep "," (
              (lib.map (d: "${config.clan.core.settings.machine.name}.${d}") domains) ++ realms
            )
          } \
          $in/my-openssh/ssh.id_ed25519.pub
        mv $in/my-openssh/ssh.id_ed25519-cert.pub $out/ssh.id_ed25519-cert.pub
      '';
    };
  };
}
