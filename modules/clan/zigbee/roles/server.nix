{ config, lib, pkgs, ... }:

let
  cfg = config.role.zigbee;

in
{
  config = {
    services.zigbee2mqtt.enable = true;
    systemd.services.zigbee2mqtt.unitConfig.ConditionPathExists = "/dev/ttyACM0";
    services.zigbee2mqtt.settings = {
      permit_join = true;
      serial.port = "/dev/ttyACM0";
      frontend = true;
      mqtt.user = "zigbee";
      mqtt.password = "password";
      network_key = "GENERATE";
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

}
