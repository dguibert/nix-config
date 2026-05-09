{
  _class = "clan.service";
  manifest.name = "totp-authentication";

  roles.default.interface =
    { lib, ... }:
    {
      options = {
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
                    description = "Whether the totp code should be prompted.";
                  };
                };
              }
            )
          );
        };
      };
    };

  roles.default.perInstance =
    {
      instanceName,
      settings,
      machine,
      roles,
      ...
    }:
    {
      nixosModule =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          userNames = builtins.attrNames settings.users;

          create_totp_prompts =
            n: v:
            if v.prompt then
              {
                name = "totp-${n}";
                value = {
                  type = "hidden";
                  persist = true;
                };
              }
            else
              { };

          create_totp_files =
            n: v:
            if !v.prompt then
              { }
            else
              {
                name = "totp-${n}";
                value = {
                  neededFor = "users";
                };
              };
        in
        {
          config = {
            security.pam.oath.enable = false;
            security.pam.services.sshd = {
              oathAuth = true;
            };
            security.pam.oath.usersFile = config.clan.core.vars.generators.oath-users.files.totp-file.path;

            clan.core.vars.generators.oath-users = {
              share = true;
              prompts = lib.mapAttrs' create_totp_prompts settings.users;
              files = {
                totp-file = {
                  owner = "root";
                  mode = "0600";
                  #path = lib.mkForce "/etc/users.oath";
                };
              }
              // (lib.mapAttrs' create_totp_files settings.users);
              runtimeInputs = [
                pkgs.openssl
              ];
              # Option User Prefix Seed (openssl rand -hex 10)
              # oathtool -v --totp -d 6 12345678909876543210
              script = ''
                ${lib.concatMapStrings (
                  n:
                  if settings.users.${n}.prompt then
                    ""
                  else
                    ''
                      openssl rand -hex 10 > $out/totp-${n}
                    ''
                ) userNames}

                cat > $out/totp-file <<EOF
                ${lib.concatMapStringsSep "\n" (n: "HOTP/T30/6 ${n} - $(cat $out/totp-${n})") userNames}
                EOF
              '';
            };

            ## https://wiki.archlinux.org/title/Pam_oath
            services.openssh.settings.PasswordAuthentication = lib.mkForce true;
            services.openssh.extraConfig = ''
              ChallengeResponseAuthentication yes
            '';
          };

        };
    };
}
