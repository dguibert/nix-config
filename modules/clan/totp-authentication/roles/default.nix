{ config, lib, pkgs, ... }:
let
  cfg = config.clan.totp-authentication;

  userNames = builtins.attrNames cfg.users;

  create_topt_prompts = n: v:
    if v.prompt then {
      name = "topt-${n}";
      value = {
        type = "hidden";
        createFile = true;
      };
    } else { };

  create_topt_files = n: v: if !v.prompt then { } else {
    name = "topt-${n}";
    value = {
      neededFor = "users";
    };
  };
in
{
  options.clan.totp-authentication = {
    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              prompt = lib.mkOption {
                type = lib.types.bool;
                default = true;
                example = false;
                description = "Whether the topt code should be prompted.";
              };
            };
          }
        )
      );
    };
  };

  config = {
    security.pam.oath.enable = false;
    security.pam.services.sshd = { oathAuth = true; };
    security.pam.oath.usersFile = config.clan.core.vars.generators.oath-users.files.topt-file.path;

    clan.core.vars.generators.oath-users = {
      share = true;
      prompts = lib.mapAttrs' create_topt_prompts cfg.users;
      files = {
        topt-file = {
          owner = "root";
          mode = "600";
          #path = lib.mkForce "/etc/users.oath";
        };
      } // (lib.mapAttrs' create_topt_files cfg.users);
      runtimeInputs = [
        pkgs.openssl
      ];
      # Option User Prefix Seed (openssl rand -hex 10)
      # oathtool -v --totp -d 6 12345678909876543210
      script = ''
        ${lib.concatMapStrings (n: if cfg.users.${n}.prompt then "" else ''
        openssl rand -hex 10 > $out/topt-${n}
        '') userNames}

        cat > $out/topt-file <<EOF
        ${lib.concatMapStrings (n: "HOTP/T30/6 ${n} - $(cat $out/topt-${n})") userNames}
        EOF
      '';
    };

    ## https://wiki.archlinux.org/title/Pam_oath
    services.openssh.settings.PasswordAuthentication = lib.mkForce true;
    services.openssh.extraConfig = ''
      ChallengeResponseAuthentication yes
    '';
  };

}
