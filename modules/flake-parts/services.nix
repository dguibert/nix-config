{ config, inputs, withSystem, self, ... }:
let
  # role-robotnix-ota-server
  role-robotnix-ota-server = [
    ../nixos/role-robotnix-ota.nix
    ({ config, lib, pkgs, inputs, ... }: {
      role.robotnix-ota-server.enable = true;
      role.robotnix-ota-server.openFirewall = true;
    })
  ];
  desktop = [
    ../nixos/wayland-conf.nix
    ../nixos/yubikey-gpg-conf.nix
    ({ config, lib, pkgs, inputs, ... }: {
      wayland-conf.enable = true;
      yubikey-gpg-conf.enable = true;
    })
  ];
  # server-3dprinting
  server-3Dprinting = [
    ../nixos/server-3Dprinting.nix
    ({ config, lib, pkgs, inputs, ... }: {
      server-3Dprinting.enable = true;
      networking.firewall.interfaces."eth0".allowedTCPPorts = [ 80 ];
    })
  ];

  # platypush
  platypush = [
    ({ config, lib, pkgs, inputs, ... }: {
      services.redis.servers."".enable = true;
    })
  ];

  # zigbee
  zigbee = [
    ({ config, lib, pkgs, inputs, ... }: {
      role.zigbee.enable = true;
    })
  ];

  microvm = [
    inputs.microvm.nixosModules.host
    ({ config, lib, pkgs, inputs, ... }: {
      role.microvm.enable = true;
    })
  ];

  waydroid = [
    ({ config, lib, pkgs, inputs, ... }: {
      virtualisation.waydroid.enable = true;
    })
  ];

  rkvm = [
    ({ config, lib, pkgs, inputs, ... }: {
      sops.secrets.rkvm-certificate.sopsFile = ../../secrets/defaults.yaml;
      sops.secrets.rkvm-key.sopsFile = ../../secrets/defaults.yaml;
      sops.secrets.rkvm-password.sopsFile = ../../secrets/defaults.yaml;
      networking.firewall.interfaces."bond0".allowedTCPPorts = lib.mkIf (config.networking.hostName == "titan") [
        5258
      ];
      services.rkvm.server = lib.mkIf (config.networking.hostName == "titan") {
        enable = true;
        settings = {
          listen = "192.168.1.24:5258";
          switch-keys = [ "middle" "left-ctrl" ];
          certificate = config.sops.secrets.rkvm-certificate.path;
          key = config.sops.secrets.rkvm-key.path;
          password = config.sops.secrets.rkvm-password.key;
        };
      };
      services.rkvm.client = lib.mkIf (config.networking.hostName != "titan") {
        enable = true;
        settings = {
          server = "192.168.1.24:5258";
          certificate = config.sops.secrets.rkvm-certificate.path;
          password = config.sops.secrets.rkvm-password.key;
        };
      };
    })
  ];

in
{
  modules.hosts.rpi31 = [ ]
    ++ server-3Dprinting
  ;
  modules.hosts.rpi41 = [ ]
    ++ zigbee
    ++ rkvm
    ++ [
    ../nixos/wayland-conf.nix
    ({ config, lib, pkgs, inputs, ... }: {
      wayland-conf.enable = true;
      hardware.graphics.enable32Bit = lib.mkForce false; # Option driSupport32Bit only makes sense on a 64-bit system.
    })
  ]
  ;
  modules.hosts.t580 = [ ]
    ++ desktop
    ++ waydroid
    #++ platypush
  ;
  #modules.hosts.titan = [ ]
  #  ++ [{
  #  networking.hosts = {
  #    "192.168.1.24" = [ "media.orsin.org" ];
  #  };
  #}]
  #  #++ role-robotnix-ota-server
  #  ++ desktop
  #  ++ platypush
  #  ++ microvm
  #  ++ rkvm
  #;
}
