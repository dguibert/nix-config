{
  flake.aspects.zigbee."clan.service" = {
    manifest.name = "zigbee";

    roles.server = {
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
              config,
              lib,
              pkgs,
              ...
            }:

            {
              clan.core.vars.generators.zigbee2mqtt = {
                files."network_key.yaml" = {
                  owner = "zigbee2mqtt";
                };
                files.user-password.deploy = false;
                files."user-password.yaml" = {
                  owner = "zigbee2mqtt";
                };
                files."user-password-hash".secret = false;
                runtimeInputs = [
                  pkgs.gnused
                  pkgs.xkcdpass
                  pkgs.mosquitto
                ];
                script = ''
                  set -x
                  xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > $out/user-password
                  echo "password: $(cat $out/user-password)" > $out/user-password.yaml

                  touch user-password-hash
                  chmod 700 user-password-hash
                  mosquitto_passwd -b user-password-hash zigbee $(cat $out/user-password)
                  cat user-password-hash | tr -d "\n" | sed -e "s@zigbee:@@" > $out/user-password-hash

                  # 16 decimals betwween 0-15
                  echo "network_key: [$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16))]" > $out/network_key.yaml
                '';
              };

              services.zigbee2mqtt.enable = true;
              systemd.services.zigbee2mqtt.unitConfig.ConditionPathExists = "/dev/ttyACM0";
              services.zigbee2mqtt.settings = {
                serial.port = "/dev/ttyACM0";
                frontend = true;
                mqtt.user = "zigbee";
                mqtt.password = "!${
                  config.clan.core.vars.generators.zigbee2mqtt.files."user-password.yaml".path
                } password";
                # 01030507090000002040608000 (hex DA37E6BABE70A2363500)
                network_key = "!${
                  config.clan.core.vars.generators.zigbee2mqtt.files."network_key.yaml".path
                } network_key";
                #includes = [
                #  config.secrets.zigbee2mqtt.secretFile
                #];
                availability = {
                  active.timeout = 10;
                  passive.timeout = 10;
                };
                channel = 26; # https://haade.fr/fr/blog/interference-zigbee-wifi-2-4ghz-a-savoir
              };

              services.mosquitto.enable = true;
              services.mosquitto.listeners = [
                {
                  users.zigbee = {
                    acl = [
                      "readwrite #"
                    ];
                    hashedPassword = config.clan.core.vars.generators.zigbee2mqtt.files."user-password-hash".value;
                  };
                }
              ];
            };

        };
    };
  };
}
