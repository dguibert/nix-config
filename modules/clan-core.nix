{
  inputs,
  config,
  lib,
  self,
  ...
}:
{
  flake-file.inputs = {
    flake-aspects.url = lib.mkDefault "github:vic/flake-aspects";
    clan-core.url = lib.mkDefault "git+https://git.clan.lol/clan/clan-core";
    clan-core.inputs.sops-nix.follows = "sops-nix";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    envfs.url = "github:Mic92/envfs";
    envfs.inputs.flake-parts.follows = "flake-parts";
    envfs.inputs.nixpkgs.follows = "nixpkgs";
    envfs.inputs.treefmt-nix.follows = "treefmt-nix";
  };

  imports = [
    inputs.flake-aspects.flakeModule
    inputs.flake-parts.flakeModules.modules # exposes flake.modules as output
    inputs.clan-core.flakeModules.default
  ];

  # Usage see: https://docs.clan.lol
  clan = {
    # Ensure this is unique among all clans you want to use.
    meta.name = "orsin-homelab";

    pkgsForSystem = system: builtins.trace "pkgsForSystem.${system}" self.legacyPackages.${system};

    specialArgs = {
      inherit inputs;
      pkgsForSystem =
        system: builtins.trace "specialArgs.pkgsForSystem.${system}" self.legacyPackages.${system};
    };

    inventory.machines.titan.tags = [
      "users"
      "desktop"
      "dguibert"
    ];
    inventory.machines.t580.tags = [
      "users"
      "desktop"
      "dguibert"
      "wifi"
    ];
    inventory.machines.rpi41.tags = [
      "users"
      "desktop64"
      "dguibert_rpi"
      "wifi"
    ];
    inventory.machines.rpi31.tags = [
      "users"
      "wifi"
      "dguibert_rpi"
    ];
    inventory.machines.rpi02.tags = [
      "users"
      "wifi"
      "dguibert_rpi"
    ];

    inventory.modules = config.flake.modules.clan;

    modules = config.flake.modules."clan.service";

    inventory.instances = {
      default-settings = {
        module.name = "importer";
        roles.default.tags.all = { };
        roles.default.extraModules = [
          (
            { config, ... }:
            {
              clan.core.networking.targetHost = config.clan.core.settings.machine.name;
            }
          )
          config.flake.modules.nixos.cacerts
          config.flake.modules.nixos.dns
          config.flake.modules.nixos.fr
          config.flake.modules.nixos.kanata
          config.flake.modules.nixos.nix
          config.flake.modules.nixos.nix-registry
          config.flake.modules.nixos.sshd
          config.flake.modules.nixos.nixpkgs
          config.flake.modules.nixos.report-changes

          config.flake.modules.nixos.user-root
          config.flake.modules.nixos.user-dguibert
        ];
      };
      _3d_printing = {
        module.input = "self";
        roles.voron02_1.machines.rpi02 = { };
      };

      haproxy = {
        module.input = "self";
        roles.default.machines.rpi41 = { };
      };

      home-manager-dguibert = {
        module.name = "importer";
        roles.default.tags.dguibert = { };
        roles.default.extraModules = [
          config.flake.modules.nixos.dguibert
          config.flake.modules.nixos.dguibert-bash
          #config.flake.modules.nixos.dguibert-custom-profile
          config.flake.modules.nixos.dguibert-emacs
          { home-manager.users.dguibert.withEmacs.enable = true; }
          config.flake.modules.nixos.dguibert-foot
          config.flake.modules.nixos.dguibert-git
          config.flake.modules.nixos.dguibert-gpg
          config.flake.modules.nixos.dguibert-htop
          config.flake.modules.nixos.dguibert-ssh
          config.flake.modules.nixos.dguibert-tmux
          config.flake.modules.nixos.dguibert-annex
          #roles.dguibert-annex.tags.dguibert = { };
        ];
      };

      home-manager-dguibert-impermanence = {
        module.name = "importer";
        roles.default.machines.titan = { };
        roles.default.machines.t580 = { };
        roles.default.extraModules = [
          config.flake.modules.nixos.impermanence
          config.flake.modules.nixos.dguibert-impermanence
        ];
      };

      home-manager-dguibert-desktop = {
        module.name = "importer";
        roles.default.tags.desktop = { };
        roles.default.extraModules = [
          # desktop
          #roles.dguibert-gui.tags.desktop = { };
          config.flake.modules.nixos.dguibert-mako
          config.flake.modules.nixos.dguibert-hyprland
          { home-manager.users.dguibert.hyprland.enable = true; }
          config.flake.modules.nixos.dguibert-with-gui
          config.flake.modules.nixos.dguibert-stylix
        ];
      };

      home-manager-dguibert-titan = {
        module.name = "importer";
        roles.default.machines.titan = { };
        roles.default.extraModules = [
          #roles.dguibert-mail.machines.titan = { };
          #roles.dguibert-3d-tools.machines.titan = { };
          #roles.dguibert-ssh-teleport.machines.titan = { };
          #roles.dguibert.machines.titan.settings.centralMailHost.enable = true;
          config.flake.modules.nixos.dguibert-vscode
          config.flake.modules.nixos.dguibert-with-3d-tools
          {
            home-manager.users.dguibert.hyprland.nvidia.enable = true;
            home-manager.users.dguibert.withVSCode.enable = true;
            home-manager.users.dguibert.centralMailHost.enable = true;
            home-manager.users.dguibert.ssh-teleport.enable = true;
          }
          ##          config.flake.modules.homeManager.dguibert-vscode

          inputs.envfs.nixosModules.envfs
          inputs.nix-ld.nixosModules.nix-ld
        ];
      };

      jellyfin = {
        module.input = "self";
        roles.default.machines.titan = { };
      };

      libvirtd = {
        module.input = "self";
        roles.default.machines.titan = { };
      };

      my-sshd = {
        module.input = "self";
        roles.client.tags.all = { };
        roles.client.settings = {
          certificate.allowEmptyDomain = true;
        };
        roles.server.tags.all = { };
        roles.server.settings = {
          certificate.allowEmptyDomain = true;
          certificate.searchDomains = [
            "orsin.net"
          ];
        };
        roles.server.machines.titan.settings.certificate.realms = [
          "192.168.1.24"
          "10.147.27.24"
          "titan.home-vpn"
        ];
        roles.server.machines.t580.settings.certificate.realms = [
          "192.168.1.17"
          "10.147.27.17"
          "t580.home-vpn"
        ];
        roles.server.machines.rpi02.settings.certificate.realms = [
          "192.168.1.12"
          "10.147.27.12"
          "rpi02.home-vpn"
        ];
        roles.server.machines.rpi31.settings.certificate.realms = [
          "192.168.1.13"
          "10.147.27.13"
          "rpi31.home-vpn"
        ];
        roles.server.machines.rpi41.settings.certificate.realms = [
          "192.168.1.14"
          "10.147.27.14"
          "82.64.121.168"
          "rpi41.home-vpn"
        ];
      };
      ollama = {
        module.input = "self";
        #roles.default.machines.titan = { };
      };
      seedbox = {
        module.input = "self";
        roles.qbittorrent.machines.titan = { };
        roles.rtorrent.machines.titan = { };
      };
      printing = {
        module.input = "self";
        roles.scan2host.machines.titan = { };
        roles.default.machines.titan = { };
        roles.default.machines.t580 = { };
      };
      rkvm = {
        module.input = "self";
        roles.server.machines.titan = { };
        roles.client.machines.rpi41 = { };
        roles.server.settings.rkvm.server = "192.168.1.24"; # TODO get from server ip
        roles.client.settings.rkvm.server = "192.168.1.24";
      };

      sshguard = {
        module.input = "self";
        roles.default.tags.all = { };
      };
      tiny-ca = {
        module.input = "self";
        roles.server.machines.titan = { };
      };
      totp-authentication = {
        module.input = "self";
        roles.default.tags.all = { };
        roles.default.settings.users.dguibert.prompt = true;
      };

      users = {
        module.input = "self";
        roles.default.tags.users = { };
        roles.default.settings.passwords.root.prompt = true;
        roles.default.settings.passwords.dguibert.prompt = true;
      };

      wayland = {
        module.input = "self";
        roles.default.tags.desktop = { };
        #roles.default.tags.desktop64.settings = {
        roles.default.machines.rpi41.settings = {
          enable32Bit = false;
        };
      };

      yubikey = {
        module.input = "self";
        roles.default.tags.desktop = { };
      };

      zigbee = {
        module.name = "zigbee";
        module.input = "self";
        roles.server.machines.rpi41 = { };
      };

      iwd = {
        module.input = "self";
        roles.default.tags.wifi = { };
        roles.default.settings = {
          networks = {
            Freebox-AD070E = { };
            Livebox-765e = { };
            Livebox-D854 = { };
            Livebox-D540 = { };
            OPTUS_ACCB7F = {
              Hidden = true;
            };
          };
        };
      };
      #  mopidy = {
      #  module.name = "mopidy";
      #  roles.default.machines.titan = { }; # TODO migrate mopidy to pipewire
      #};
      microvm = {
        module.input = "self";
        roles.default.machines.titan = { };
      };

      openvpn-cdac = {
        module.input = "self";
        roles.default.machines.titan = { };
      };

      home-vpn = {
        # TODO add networking.wireguard.useNetworkd = true; # (defined in default.nix)
        module.name = "wireguard";
        module.input = "clan-core";
        roles.controller.machines.rpi41.settings = {
          endpoint = "82.64.121.168";
          port = 51820; # default UDP port
        };
        roles.peer.machines = {
          titan.settings.controller = "rpi41";
          t580 = { };
          rpi02 = { };
          rpi31 = { };
        };
      };

      distributed-build = {
        module.input = "self";
        roles.server.machines.rpi41 = { };
        roles.client.tags.all = { };
      };
    };

    # Prerequisite: boot into the installer.
    # All machines in the ./machines will be imported.
    # See: https://docs.clan.lol/getting-started/installer
    # local> mkdir -p ./machines/machine1
    # local> Edit ./machines/<machine>/configuration.nix to your liking.
  };
}
