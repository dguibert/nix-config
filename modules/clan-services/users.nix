{
  _class = "clan.service";
  manifest.name = "users";

  roles.default = {
    interface =
      { lib, ... }:
      {
        options = {
          passwords = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { ... }:
                {
                  options = {
                    prompt = lib.mkOption {
                      type = lib.types.bool;
                      default = true;
                      example = false;
                      description = "Whether the user should be prompted.";
                    };
                  };
                }
              )
            );
          };
        };

      };

    perInstance =
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
            pkgs,
            config,
            lib,
            ...
          }:
          let
            secret_generator = name: value: {
              name = "${name}-password";
              value = {
                prompts =
                  if value.prompt then
                    {
                      user-password.type = "hidden";
                      user-password.persist = true;
                    }
                  else
                    { };

                files = {
                  user-password-hash.neededFor = "users";
                }
                // (
                  if !value.prompt then
                    {
                      user-password.deploy = false;
                    }
                  else
                    { }
                );
                runtimeInputs = [
                  pkgs.coreutils
                  pkgs.xkcdpass
                  pkgs.mkpasswd
                ];
                script = ''
                  set -x
                ''
                + (
                  if (!value.prompt) then
                    ''
                      xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > $out/user-password
                    ''
                  else
                    ""
                )
                + ''
                  cat $out/user-password | mkpasswd -s -m sha-512 | tr -d "\n" > $out/user-password-hash
                '';
              };
            };

            create_user = name: value: {
              inherit name;
              value = {
                hashedPasswordFile =
                  config.clan.core.vars.generators."${name}-password".files.user-password-hash.path;
                #isNormalUser = lib.mkDefault true;
              };
            };

          in
          {
            config = lib.mkMerge [
              (lib.mkIf (settings.passwords != { }) {
                users.mutableUsers = false;
                users.users = lib.mapAttrs' create_user settings.passwords;
                clan.core.vars.generators = lib.mapAttrs' secret_generator settings.passwords;
              })
            ];
          };
      };
  };
}
