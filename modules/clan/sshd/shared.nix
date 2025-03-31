{ config
, lib
, pkgs
, ...
}:
{
  options = {
    clan.sshd.certificate = {
      allowEmptyDomain = lib.mkEnableOption "Allow * as searched domain";
      # TODO: allow per-server domains that we than collect in the inventory
      #domains = lib.mkOption {
      #  type = lib.types.listOf lib.types.str;
      #  default = [ ];
      #  example = [ "git.mydomain.com" ];
      #  description = "List of domains to include in the certificate. This option will not prepend the machine name in front of each domain.";
      #};
      realms = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "git.mydomain.com" ];
        description = "List of realms to include in the certificate. This option will not prepend the machine name in front of each realm.";
      };
      searchDomains = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "mydomain.com" ];
        description = "List of domains to include in the certificate. This option will prepend the machine name in front of each domain before adding it to the certificate.";
      };
    };
  };
  config = {
    clan.core.vars.generators.openssh-ca =
      lib.mkIf (config.clan.sshd.certificate.searchDomains != [ ])
        {
          share = true;
          files.id_ed25519.deploy = false;
          files."id_ed25519.pub" = {
            deploy = false;
            secret = false;
          };
          runtimeInputs = [
            pkgs.openssh
          ];
          script = ''
            ssh-keygen -t ed25519 -N "" -f $out/id_ed25519
          '';
        };

    programs.ssh.knownHosts.ssh-ca = {
      certAuthority = true;
      extraHostNames = builtins.map (domain: "*.${domain}") config.clan.sshd.certificate.searchDomains
        ++ lib.optional config.clan.sshd.certificate.allowEmptyDomain "*";
      publicKey = config.clan.core.vars.generators.openssh-ca.files."id_ed25519.pub".value;
    };
  };
}
