{
  description = "Configurations of my systems";

  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs.home-manager.url = "github:dguibert/home-manager/pu";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  #inputs.nix.follows = "nur_packages/nix";
  inputs.nix.url = "github:dguibert/nix/pu";
  inputs.nur_packages.inputs.nix.follows = "nix";

  inputs.nur.url = "github:nix-community/NUR";
  inputs.sops-nix.url = "github:dguibert/sops-nix/pu"; # for dg/use-with-cross-system
  inputs.sops-nix.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  #inputs.nixpkgs.url = "path:nixpkgs";
  inputs.nixpkgs.url = "github:dguibert/nix-config?dir=nixpkgs";
  inputs.nixpkgs.inputs.nixpkgs.follows = "nur_packages";
  inputs.upstream_nixpkgs.url = "github:dguibert/nixpkgs/pu";
  inputs.nur_packages.url = "github:dguibert/nur-packages?refs=master";
  inputs.nur_packages.inputs.nixpkgs.follows = "upstream_nixpkgs";
  inputs.nur_packages.inputs.git-hooks-nix.follows = "git-hooks-nix";
  inputs.nur_packages.inputs.nix.inputs.flake-compat.follows = "flake-compat";

  inputs.disko.url = "github:nix-community/disko";
  #inputs.disko.url = github:dguibert/disko;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.terranix = {
    url = "github:mrVanDalo/terranix";
    flake = false;
  };
  #inputs."nixos-18.03".url   = "github:nixos/nixpkgs-channels/nixos-18.03";
  #inputs."nixos-18.09".url   = "github:nixos/nixpkgs-channels/nixos-18.09";
  #inputs."nixos-19.03".url   = "github:nixos/nixpkgs-channels/nixos-19.03";
  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.home-manager.follows = "home-manager";
  inputs.stylix.inputs.base16.follows = "base16";
  inputs.stylix.inputs.base16-vim.follows = "base16-vim";
  inputs.stylix.inputs.flake-compat.follows = "flake-compat";
  inputs.stylix.inputs.git-hooks.follows = "git-hooks-nix";

  inputs.base16.url = "github:SenchoPens/base16.nix";
  #inputs.base16.inputs.nixpkgs.follows = "nixpkgs";
  inputs.tt-schemes = {
    url = "github:tinted-theming/schemes";
    flake = false;
  };
  inputs.base16-vim = {
    url = "github:tinted-theming/base16-vim";
    flake = false;
  };
  inputs.base16-shell = {
    url = "github:tinted-theming/tinted-shell";
    flake = false;
  };
  inputs.gitignore = {
    url = "github:hercules-ci/gitignore";
    flake = false;
  };

  inputs.nxsession.url = "github:dguibert/nxsession";
  inputs.nxsession.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
  inputs.nxsession.inputs.flake-utils.follows = "nur_packages/flake-utils";

  # For accessing `deploy-rs`'s utility Nix functions
  inputs.deploy-rs.url = "github:dguibert/deploy-rs/pu";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
  inputs.deploy-rs.inputs.flake-compat.follows = "flake-compat";

  #inputs.nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
  # only needed if you use as a package set:
  #inputs.nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
  #inputs.nixpkgs-wayland.inputs.master.follows = "master";
  #inputs.emacs-overlay.url = "github:nix-community/emacs-overlay";
  inputs.emacs-overlay.follows = "nur_packages/emacs-overlay";

  inputs.flake-parts.follows = "nur_packages/flake-parts";
  inputs.flake-utils.follows = "nur_packages/flake-utils";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";
  inputs.git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs/nixpkgs/nixpkgs";
  inputs.git-hooks-nix.inputs.flake-compat.follows = "flake-compat";

  #inputs.hyprland.url = "github:hyprwm/Hyprland";
  #inputs.hyprland.url = "git+https://github.com/dguibert/Hyprland?submodules=1";
  inputs.hyprland.url = "github:dguibert/Hyprland?ref=refs/heads/main&submodules=1";
  inputs.hyprland.inputs.nixpkgs.follows = "nixpkgs";
  inputs.hyprland.inputs.systems.follows = "systems";
  inputs.hyprland.inputs.pre-commit-hooks.follows = "git-hooks-nix";
  inputs.hyprsplit.url = "github:dguibert/hyprsplit";
  inputs.hyprsplit.inputs.hyprland.follows = "hyprland";

  inputs.hyprland-contrib = {
    url = "github:hyprwm/contrib";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  #inputs.eww = {
  #  url = "github:elkowar/eww";
  #  inputs.nixpkgs.follows = "nur_packages";
  #  inputs.rust-overlay.follows = "rust-overlay";
  #};
  inputs.nix-ld.url = "github:Mic92/nix-ld";
  # this line assume that you also have nixpkgs as an input
  inputs.nix-ld.inputs.nixpkgs.follows = "nixpkgs";

  inputs.envfs.url = "github:Mic92/envfs";
  inputs.envfs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.envfs.inputs.treefmt-nix.follows = "treefmt-nix";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-wsl.inputs.flake-compat.follows = "flake-compat";

  #inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.url = "github:dguibert/impermanence";

  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  #inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  #inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  inputs.clan-core.url = "git+https://git.clan.lol/clan/clan-core";
  inputs.clan-core.inputs.sops-nix.follows = "sops-nix";
  inputs.clan-core.inputs.disko.follows = "disko";
  inputs.clan-core.inputs.treefmt-nix.follows = "treefmt-nix";
  inputs.clan-core.inputs.nixpkgs.follows = "nixpkgs/nixpkgs"; # Needed if your configuration uses nixpkgs unstable.
  # New
  inputs.clan-core.inputs.flake-parts.follows = "flake-parts";

  inputs.systems.follows = "clan-core/systems";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  inputs.flake-compat.url = "github:edolstra/flake-compat";

  nixConfig.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

  outputs =
    {
      self,
      flake-parts,
      systems,
      ...
    }@inputs:
    let
      # Memoize nixpkgs for different platforms for efficiency.
      inherit (self) outputs;
      lib = inputs.nur_packages.lib;

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        overlays = import ./overlays {
          inherit inputs;
          lib = inputs.nur_packages.lib;
        };

        deploy.nodes = builtins.foldl' inputs.nur_packages.lib.recursiveUpdate { } [
          (inputs.nur_packages.lib.mapAttrs
            (
              host: nixosConfig:
              let
                system = nixosConfig.config.nixpkgs.localSystem.system;
              in
              {
                hostname = "${nixosConfig.config.networking.hostName}";
                sshOpts = [
                  "-o"
                  "ControlMaster=no"
                ]; # https://github.com/serokell/deploy-rs/issues/106
                profilesOrder = [
                  "system"
                  "dguibert"
                ];
                profiles.system.path = self.legacyPackages.${system}.deploy-rs.lib.activate.nixos nixosConfig;
                profiles.system.user = "root";
                # Fast connection to the node. If this is true, copy the whole closure instead of letting the node substitute.
                fastConnection = true;

                # If the previous profile should be re-activated if activation fails.
                autoRollback = true;

                # See the earlier section about Magic Rollback for more information.
                # This defaults to `true`
                magicRollback = false;
              }
            )
            (
              builtins.removeAttrs self.nixosConfigurations [
                "iso"
                "iso-aarch64"
              ]
            )
          )
          # root profiles
          (inputs.nur_packages.lib.mapAttrs
            (
              host: homeConfig:
              let
                system = self.nixosConfigurations.${host}.config.nixpkgs.localSystem.system;
              in
              {
                #profiles.root.path = inputs.deploy-rs.lib.aarch64-linux.activate.custom
                profiles.dguibert.path =
                  self.legacyPackages.${system}.deploy-rs.lib.activate.custom homeConfig.activationPackage
                    "./activate";
                profiles.dguibert.user = "root";
              }
            )
            {
              rpi31 = self.homeConfigurations."root@rpi31";
              rpi41 = self.homeConfigurations."root@rpi41";
              titan = self.homeConfigurations."root@titan";
              t580 = self.homeConfigurations."root@t580";
            }
          )
          (
            let
              genProfile = user: name: profile: {
                path =
                  self.legacyPackages.x86_64-linux.deploy-rs.lib.activate.custom
                    self.homeConfigurations."${name}".activationPackage
                    ''
                      export NIX_STATE_DIR=${self.homeConfigurations."${name}".config.home.sessionVariables.NIX_STATE_DIR}
                      export NIX_PROFILE=${self.homeConfigurations."${name}".config.home.sessionVariables.NIX_PROFILE}
                      ./activate
                    '';
                sshUser = user;
                profilePath = "${builtins.dirOf builtins.storeDir}/var/nix/profiles/per-user/${user}/${profile}";
              };
            in
            {
              #genji = {
              #  hostname = "genji";
              #  sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
              #  fastConnection = true;
              #  autoRollback = false;
              #  magicRollback = false;

              #  profiles.bguibertd = genProfile "bguibertd" "bguibertd@genji" "hm-x86_64";
              #};
              spartan = {
                hostname = "spartan";
                sshOpts = [
                  "-o"
                  "ControlMaster=no"
                ]; # https://github.com/serokell/deploy-rs/issues/106
                fastConnection = true;
                autoRollback = false;
                magicRollback = false;

                profiles.bguibertd = genProfile "bguibertd" "bguibertd@spartan" "hm";
                profiles.bguibertd-x86_64 = genProfile "bguibertd" "bguibertd@spartan-x86_64" "hm-x86_64";
                profiles.bguibertd-aarch64 = genProfile "bguibertd" "bguibertd@spartan-aarch64" "hm-aarch64";
              };
              #levante = {
              #  hostname = "levante";
              #  sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
              #  fastConnection = true;
              #  autoRollback = false;
              #  magicRollback = false;

              #  profiles.dguibert = genProfile "b381115" "dguibert@levante" "hm";

              #};
              #lumi = {
              #  hostname = "lumi";
              #  sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
              #  fastConnection = true;
              #  autoRollback = false;
              #  magicRollback = false;

              #  profiles.dguibert = genProfile "dguibert" "dguibert@lumi" "hm";

              #};
            }
          )

          ({ })
        ];

      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [
        inputs.clan-core.flakeModules.default
        #./home/profiles
        ./homes
        ./hosts
        ./modules/all-modules.nix
        ./apps
        ./checks
        ./shells
      ];
      # Usage see: https://docs.clan.lol
      clan = {
        # Ensure this is unique among all clans you want to use.
        meta.name = "orsin.homelab";

        pkgsForSystem = system: builtins.trace "pkgsForSystem.${system}" self.legacyPackages.${system};

        specialArgs = {
          inherit inputs;
          self' = self;
          pkgsForSystem =
            system: builtins.trace "specialArgs.pkgsForSystem.${system}" self.legacyPackages.${system};
        };

        inventory.machines.titan.tags = [
          "desktop"
          "dguibert"
        ];
        inventory.machines.t580.tags = [
          "desktop"
          "dguibert"
          "wifi"
        ];
        inventory.machines.rpi41.tags = [
          "desktop64"
          "dguibert_rpi"
        ];
        inventory.machines.rpi31.tags = [
          "wifi"
          "dguibert_rpi"
        ];

        inventory.modules = self.modules.clan;
        modules = self.modules.clan-services;

        inventory.instances.voron02_1 = {
          module.name = "_3d_printing";
          roles.voron02_1.machines.rpi31 = { };
        };

        inventory.instances.adb = {
          module.name = "adb";
          roles.default.machines.t580 = { };
          roles.default.machines.titan = { };
        };

        inventory.instances.haproxy = {
          module.name = "haproxy";
          roles.default.machines.rpi41 = { };
        };

        inventory.instances.home-manager-dguibert = {
          module.name = "home-manager";
          roles.dguibert.tags.dguibert = { };
          roles.dguibert-emacs.tags.dguibert = { };
          roles.dguibert.settings = {
            withPersistence.enable = true;
            withZellij.enable = true;
            #centralMailHost.enable = lib.mkDefault false;
          };
        };
        inventory.instances.jellyfin = {
          module.name = "jellyfin";
          roles.default.machines.titan = { };
        };
        inventory.instances.libvirtd = {
          module.name = "libvirtd";
          roles.default.machines.titan = { };
        };
        #inventory.instances.home-manager.dguibert-emacs.roles.dguibert-emacs.tags = [ "dguibert" ];
        #inventory.instances.home-manager.dguibert.config.dguibert = {
        #};
        #inventory.instances.home-manager.dguibert_rpi.roles.dguibert.tags = [ "dguibert_rpi" ];
        #inventory.instances.home-manager.dguibert_rpi.config.dguibert = {
        #  withPersistence.enable = false;
        #};
        #inventory.instances.home-manager.desktop.roles.dguibert.tags = [ "desktop" ];
        #inventory.instances.home-manager.desktop.config.dguibert.withGui.enable = true;
        #inventory.instances.home-manager.centralMailHost.roles.dguibert.machines = [ "titan" ];
        #inventory.instances.home-manager.centralMailHost.config.dguibert.centralMailHost.enable = true;

        inventory.services = {
          my-sshd.service.roles.client.tags = [ "all" ];
          my-sshd.service.roles.server.tags = [ "all" ];
          my-sshd.service.roles.server.config = {
            certificate.searchDomains = [
              "orsin.net"
            ];
          };
          importer.sshd = {
            roles.default.tags = [ "all" ];
            roles.default.extraModules = [
              "modules/nixos/sshd.nix"
            ];
          };

          ollama.titan.roles.default.machines = [ "titan" ];
          tiny-ca.orsin.roles.server.machines = [ "titan" ];
          #mopidy.titan.roles.default.machines = [ "titan" ];
          rkvm.desktop = {
            roles.server.machines = [ "titan" ];
            roles.client.machines = [ "rpi41" ];
            config.server = "192.168.1.24";
          };

          wayland.instance_1.roles.default.tags = [ "desktop" ];
          wayland.instance_2.roles.default.tags = [ "desktop64" ];
          wayland.instance_2.config.enable32Bit = false;

          yubikey.instance_1.roles.default.tags = [ "desktop" ];

          zigbee.instance_1.roles.server.machines = [ "rpi41" ];

          sshguard.service.roles.default.tags = [ "all" ];

          totp-authentication.service.roles.default.tags = [ "all" ];
          totp-authentication.service.config.users.dguibert.prompt = true;

          wireguard-mesh-vpn.service.roles.peer.tags = [ "all" ];
          wireguard-mesh-vpn.service.config.peers = {
            rpi31.listenPort = 500;
            rpi31.endpoint = "192.168.1.13";
            rpi41.listenPort = 501;
            rpi41.endpoint = "82.64.121.168";
            rpi41.persistentKeepalive = 25;
            titan.listenPort = 502;
            titan.endpoint = "192.168.1.24";
            t580.listenPort = 503;
            t580.endpoint = "192.168.1.17";
          };

          wifi.instance.roles.default.tags = [ "wifi" ];
          wifi.instance.config = {
            networks = {
              Freebox-AD070E = { };
              Livebox-765e = { };
              Livebox-D854 = { };
              Livebox-D540 = { };
              OPTUS_ACCB7F = { };
            };
          };

          users.root.roles.default.tags = [ "all" ];
          users.root.config.passwords.root.prompt = true;
          users.dguibert.roles.default.tags = [ "dguibert" ];
          users.dguibert.config.passwords.dguibert.prompt = true;

          printing.instance.roles.scan2host.machines = [ "titan" ];
          printing.instance.roles.client.machines = [
            "titan"
            "t580"
          ];
        };

        # Prerequisite: boot into the installer.
        # All machines in the ./machines will be imported.
        # See: https://docs.clan.lol/getting-started/installer
        # local> mkdir -p ./machines/machine1
        # local> Edit ./machines/<machine>/configuration.nix to your liking.
      };

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          # This is highly advised, and will prevent many possible mistakes
          checks = (self.legacyPackages.${system}.deploy-rs.lib.deployChecks inputs.self.deploy);

        };
    };

}
