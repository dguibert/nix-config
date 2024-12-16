{ config, inputs, withSystem, self, ... }:
let
  # role-libvirtd
  role-libvirtd = [
    ../nixos/role-libvirtd.nix
    ({ config, lib, pkgs, inputs, ... }: {
      # https://nixos.org/nixops/manual/#idm140737318329504
      role.libvirtd.enable = true;
      #virtualisation.anbox.enable = true;
      #services.nfs.server.enable = true;
      virtualisation.docker.enable = true;
      virtualisation.docker.enableOnBoot = false; #start by socket activation
      virtualisation.docker.storageDriver = "zfs";
      services.dockerRegistry.enable = true;

      programs.singularity.enable = true;
    })
  ];
  # role-tinyca
  role-tinyca = [
    ../nixos/role-tiny-ca.nix
    ({ config, lib, pkgs, inputs, ... }: {
      role.tiny-ca.enable = true;
      services.step-ca.intermediatePasswordFile = config.sops.secrets.orsin-ca-intermediatePassword.path;
      sops.secrets.orsin-ca-intermediatePassword = {
        sopsFile = ../../secrets/defaults.yaml;
      };
      networking.firewall.interfaces."bond0".allowedTCPPorts = [
        config.services.step-ca.port
      ];
    })
  ];
  # role-robotnix-ota-server
  role-robotnix-ota-server = [
    ../nixos/role-robotnix-ota.nix
    ({ config, lib, pkgs, inputs, ... }: {
      role.robotnix-ota-server.enable = true;
      role.robotnix-ota-server.openFirewall = true;
    })
  ];
  # mopidy-server
  role-mopidy = [
    ../nixos/role-mopidy.nix
    ({ config, lib, pkgs, inputs, ... }: {
      role.mopidy-server.enable = true; # TODO migrate to pipewire
      role.mopidy-server.listenAddress = "192.168.1.24";
      role.mopidy-server.configuration.local.media_dir = "/home/dguibert/Music/mopidy";
      role.mopidy-server.configuration.m3u = {
        enabled = true;
        playlists_dir = "/home/dguibert/Music/playlists";
        base_dir = config.role.mopidy-server.configuration.local.media_dir;
        default_extension = ".m3u8";
      };
      role.mopidy-server.configuration.local.scan_follow_symlinks = true;
      role.mopidy-server.configuration.iris.country = "FR";
      role.mopidy-server.configuration.iris.locale = "FR";
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
  #  ++ adb
  #  ++ [{
  #  networking.hosts = {
  #    "192.168.1.24" = [ "media.orsin.org" ];
  #  };
  #}]
  #  ++ role-libvirtd
  #  ++ role-tinyca
  #  #++ role-robotnix-ota-server
  #  #++ role-mopidy
  #  ++ desktop
  #  ++ platypush
  #  ++ microvm
  #  ++ rkvm
  #;
}
