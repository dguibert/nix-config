{ config, inputs, withSystem, self, ... }:
let
  haproxy = [
    ({ config, lib, pkgs, inputs, ... }:
      let
        haproxy_internal_ip = "192.168.127.254";
      in
      {
        networking.firewall.allowedTCPPorts = [ 443 ];
        systemd.network.netdevs."40-haproxy" = {
          netdevConfig = {
            Name = "haproxy";
            Kind = "dummy";
          };
        };
        systemd.network.networks."40-haproxy" = {
          name = "haproxy";
          networkConfig.Address = "${haproxy_internal_ip}/32";
          routingPolicyRules = [
            {
              From = "${haproxy_internal_ip}";
              Table = "103";
            }
          ];
          routes = [
            {
              Destination = "0.0.0.0/0";
              Type = "local";
              Table = "103";
            }
          ];
        };
        services.haproxy.enable = true;
        ### https://datamakes.com/2018/02/17/high-intensity-port-sharing-with-haproxy/
        services.haproxy.config = ''
          defaults
            log  global
            timeout connect 10s
            timeout client 36h
            timeout server 36h
          global
            log /dev/log  local0 debug

          listen sslh
            mode tcp
            bind 0.0.0.0:443 transparent
            tcp-request inspect-delay 15s
            tcp-request content accept if { req.ssl_hello_type 1 }

            #acl    ssh_payload        payload(0,7)    -m bin 5353482d322e30
            acl ssh_payload req.payload(0,7) -m str "SSH-2.0"
            #tcp-request content reject if !ssh_payload
            #tcp-request content accept if { req_ssl_hello_type 1 }

            use_backend openssh            if ssh_payload
            use_backend openssh            if !{ req.ssl_hello_type 1 } { req.len 0 }
            use_backend shadowsocks        if !{ req.ssl_hello_type 1 } !{ req.len 0 }
            timeout client 2h
            log global

          backend openssh
            mode tcp
            server openssh ${haproxy_internal_ip}:44322 source 0.0.0.0 usesrc clientip
            timeout server 2h
            log global
          backend shadowsocks
            mode tcp
            server socks ${haproxy_internal_ip}:${toString config.services.shadowsocks.port} source 0.0.0.0 usesrc clientip
            log global
        '';
        services.haproxy.user = "root"; # for transparent
        # Enable the OpenSSH daemon.
        services.openssh.enable = true;
        services.openssh.listenAddresses = [
          { addr = "127.0.0.1"; port = 44322; }
          { addr = "${haproxy_internal_ip}"; port = 44322; }
        ];

        #echo -n "ss://"`echo -n chacha20-ietf-poly1305:$(sops --extract '["shadowsocks"]' -d hosts/rpi31/secrets/secrets.yaml)@$(curl -4 ifconfig.io):443 | base64` | qrencode -t UTF8
        sops.secrets.shadowsocks.sopsFile = ../../hosts/rpi41/secrets/secrets.yaml;
        services.shadowsocks = {
          enable = true;
          localAddress = [ haproxy_internal_ip ];
          port = 8388;
          passwordFile = config.sops.secrets.shadowsocks.path;
        };
      })
  ];

  adb = [ ({ ... }: { programs.adb.enable = true; }) ];

  jellyfin = [
    ({ config, lib, pkgs, inputs, ... }: {
      _file = "services.nix[jellyfin]";
      config = {
        services.jellyfin.enable = true;
        systemd.services.jellyfin = lib.mkIf config.services.jellyfin.enable {
          serviceConfig.PrivateUsers = lib.mkForce false;
          serviceConfig.PermissionsStartOnly = true;
          preStart = ''
            set -x
            #${pkgs.acl}/bin/setfacl -Rm u:jellyfin:rwX,m:rw-,g:jellyfin:rwX,d:u:jellyfin:rwX,d:g:jellyfin:rwX,o:---,d:o:---,d:m:rwx,m;rwx /home/dguibert/Videos/Series/ /home/dguibert/Videos/Movies/
            ${pkgs.acl}/bin/setfacl -m user:jellyfin:r-x /home/dguibert
            ${pkgs.acl}/bin/setfacl -m user:jellyfin:r-x /home/dguibert/Videos
            ${pkgs.acl}/bin/setfacl -m user:jellyfin:rwx /home/dguibert/Videos/Series
            ${pkgs.acl}/bin/setfacl -m user:jellyfin:rwx /home/dguibert/Videos/Movies
            ${pkgs.acl}/bin/setfacl -m group:jellyfin:r-x /home/dguibert
            ${pkgs.acl}/bin/setfacl -m group:jellyfin:r-x /home/dguibert/Videos
            ${pkgs.acl}/bin/setfacl -m group:jellyfin:rwx /home/dguibert/Videos/Series
            ${pkgs.acl}/bin/setfacl -m group:jellyfin:rwx /home/dguibert/Videos/Movies
            set +x
          '';
          unitConfig.RequiresMountsFor = "/home/dguibert/Videos";
        };
        networking.firewall.interfaces."bond0".allowedTCPPorts = [
          8096 /*http*/
          8920 /*https*/
        ];
        systemd.tmpfiles.rules = [
          "L /var/lib/jellyfin/config - - - - /persist/var/lib/jellyfin/config"
          "L /var/lib/jellyfin/data   - - - - /persist/var/lib/jellyfin/data"
        ];

      };
    })
  ];

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
    ++ haproxy
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
    ++ adb
    ++ desktop
    ++ waydroid
    #++ platypush
  ;
  modules.hosts.titan = [ ]
    ++ adb
    ++ jellyfin
    ++ [{
    networking.hosts = {
      "192.168.1.24" = [ "media.orsin.org" ];
    };
  }]
    ++ role-libvirtd
    ++ role-tinyca
    #++ role-robotnix-ota-server
    #++ role-mopidy
    ++ desktop
    ++ platypush
    ++ microvm
    ++ rkvm
  ;
}
