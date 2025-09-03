{
  _class = "clan.service";
  manifest.name = "iwd";

  roles.default = {
    interface =
      { lib, ... }:
      {
        options = {
          networks = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { name, ... }:
                {
                  options = {
                    ssid = lib.mkOption {
                      type = lib.types.str;
                      default = name;
                      description = "The name of the wifi network";
                    };
                    AutoConnect = lib.mkOption {
                      type = lib.types.bool;
                      default = true;
                      description = "Automatically try to join this wifi network";
                    };
                    Hidden = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "this wifi network is hidden";
                    };
                  };
                }
              )
            );
            default = { };
            description = "Wifi networks to predefine";
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
            lib,
            config,
            pkgs,
            ...
          }:

          let
            secret_path = ssid: config.clan.core.vars.generators."iwd.${ssid}".files."iwd.${ssid}".path;
            secret_generator = name: value: {
              name = "iwd.${value.ssid}";
              value =
                let
                  secret_name = "iwd.${value.ssid}";
                in
                {
                  prompts.${secret_name} = {
                    description = "Wifi password for '${value.ssid}'";
                    persist = true;
                  };
                  migrateFact = secret_name;
                  # ref. man iwd.network
                  script = ''
                    config="
                    [Settings]
                      AutoConnect=${if value.AutoConnect then "true" else "false"}
                      ${if value.Hidden then "Hidden=true" else ""}
                    [Security]
                      Passphrase=$(echo -e "$out/${secret_name}" | ${lib.getExe pkgs.gnused} "s=\\\=\\\\\\\=g;s=\t=\\\t=g;s=\r=\\\r=g;s=^ =\\\s=")
                    "
                    echo "$config" > "$out/${secret_name}"
                  '';
                };
            };
          in
          {
            config = lib.mkMerge [
              (lib.mkIf (settings.networks != { }) {
                # Systemd tmpfiles rule to create /var/lib/iwd/example.psk file
                systemd.tmpfiles.rules = lib.mapAttrsToList (
                  _: value: "C /var/lib/iwd/${value.ssid}.psk 0600 root root - ${secret_path value.ssid}"
                ) settings.networks;

                clan.core.vars.generators = lib.mapAttrs' secret_generator settings.networks;

                # TODO: restart the iwd.service if something changes
              })
              {
                # disable wpa supplicant
                networking.wireless.enable = false;

                # Set the network manager backend to iwd
                networking.networkmanager.wifi.backend = "iwd";

                # Use iwd instead of wpa_supplicant. It has a user friendly CLI
                networking.wireless.iwd = {
                  enable = true;
                  settings = {
                    Network = {
                      EnableIPv6 = true;
                      RoutePriorityOffset = 300;
                    };
                    Settings.AutoConnect = true;
                  };
                };
              }
            ];
          };
      };
  };
}
