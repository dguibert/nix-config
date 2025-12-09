{
  _class = "clan.service";
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
              files."network_key.yaml" = { };
              script = ''
                # 16 decimals betwween 0-15
                echo "network_key: [$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16)),$((RANDOM%16))]" > $out/network_key.yaml
              '';
            };

            services.zigbee2mqtt.enable = true;
            systemd.services.zigbee2mqtt.unitConfig.ConditionPathExists = "/dev/ttyACM0";
            services.zigbee2mqtt.settings = {
              permit_join = true;
              serial.port = "/dev/ttyACM0";
              frontend = true;
              mqtt.user = "zigbee";
              mqtt.password = "password";
              # 01030507090000002040608000 (hex DA37E6BABE70A2363500)
              network_key = "'!${
                clan.core.vars.generators.zigbee2mqtt.files."network_key.yaml".path
              } network_key'";
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
                  # nix shell nixpkgs#mosquitto --command mosquitto_passwd -c /tmp/password zigbee
                  hashedPassword = "$7$101$hjkpxbnBRKvg9ZdL$wlF214j+mWx17ccKDapsnBzcfsZiDGkM9f/ugKOw7GAwYttG+mdtWVpkakB6mee0i7lJl102lnmu48BoVKpfmg==";
                };
                users.root = {
                  acl = [
                    "readwrite #"
                  ];
                  # nix shell nixpkgs#mosquitto --command mosquitto_passwd -c /tmp/password root
                  hashedPassword = "$7$101$hjkpxbnBRKvg9ZdL$wlF214j+mWx17ccKDapsnBzcfsZiDGkM9f/ugKOw7GAwYttG+mdtWVpkakB6mee0i7lJl102lnmu48BoVKpfmg==";
                };
              }
            ];
          };

      };
  };
}
