{
  description = "Configurations of my systems";

  flake-file.inputs = {   # To update all inputs:
    flake-parts.url = "github:hercules-ci/flake-parts";
  # $ nix flake update --recreate-lock-file
  home-manager.url = "github:dguibert/home-manager/pu";
  home-manager.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  #nix.follows = "nur_packages/nix";
  nix.url = "github:dguibert/nix/pu";
  nix.inputs.flake-compat.follows = "flake-compat";
  nix.inputs.flake-parts.follows = "flake-parts";
  nix.inputs.git-hooks-nix.follows = "git-hooks-nix";
  nix.inputs.nixpkgs.follows = "nixpkgs";
  nur_packages.inputs.nix.follows = "nix";

  sops-nix.url = "github:dguibert/sops-nix/pu"; # for dg/use-with-cross-system
  sops-nix.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  #nixpkgs.url = "path:nixpkgs";
  nixpkgs.url = "github:dguibert/nix-config?dir=nixpkgs";
  nixpkgs.inputs.nixpkgs.follows = "nur_packages";
  upstream_nixpkgs.url = "github:dguibert/nixpkgs/pu";
  nur_packages.url = "github:dguibert/nur-packages?ref=master";
  nur_packages.inputs.nixpkgs.follows = "upstream_nixpkgs";
  nur_packages.inputs.git-hooks-nix.follows = "git-hooks-nix";
  nur_packages.inputs.nix.inputs.flake-compat.follows = "flake-compat";

  disko.url = "github:nix-community/disko";
  #disko.url = github:dguibert/disko;
  disko.inputs.nixpkgs.follows = "nixpkgs";

  terranix = {
    url = "github:mrVanDalo/terranix";
    flake = false;
  };
  #"nixos-18.03".url   = "github:nixos/nixpkgs-channels/nixos-18.03";
  #"nixos-18.09".url   = "github:nixos/nixpkgs-channels/nixos-18.09";
  #"nixos-19.03".url   = "github:nixos/nixpkgs-channels/nixos-19.03";
  stylix.url = "github:danth/stylix";
  stylix.inputs.base16.follows = "base16";
  stylix.inputs.base16-vim.follows = "base16-vim";
  stylix.inputs.flake-parts.follows = "flake-parts";
  stylix.inputs.nixpkgs.follows = "nixpkgs";
  stylix.inputs.systems.follows = "systems";

  base16.url = "github:SenchoPens/base16.nix";
  #base16.inputs.nixpkgs.follows = "nixpkgs";
  tt-schemes = {
    url = "github:tinted-theming/schemes";
    flake = false;
  };
  base16-vim = {
    url = "github:tinted-theming/base16-vim";
    flake = false;
  };
  base16-shell = {
    url = "github:tinted-theming/tinted-shell";
    flake = false;
  };
  gitignore = {
    url = "github:hercules-ci/gitignore";
    flake = false;
  };

  nxsession.url = "github:dguibert/nxsession";
  nxsession.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
  nxsession.inputs.flake-utils.follows = "nur_packages/flake-utils";

  # For accessing `deploy-rs`'s utility Nix functions
  deploy-rs.url = "github:dguibert/deploy-rs/pu";
  deploy-rs.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
  deploy-rs.inputs.flake-compat.follows = "flake-compat";
  deploy-rs.inputs.utils.follows = "nur_packages/flake-utils";

  #nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
  # only needed if you use as a package set:
  #nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
  #nixpkgs-wayland.inputs.master.follows = "master";
  #emacs-overlay.url = "github:nix-community/emacs-overlay";
  emacs-overlay.follows = "nur_packages/emacs-overlay";

  flake-parts.follows = "nur_packages/flake-parts";
  flake-utils.follows = "nur_packages/flake-utils";
  flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  git-hooks-nix.url = "github:cachix/git-hooks.nix";
  git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs/nixpkgs/nixpkgs";
  git-hooks-nix.inputs.flake-compat.follows = "flake-compat";

  #hyprland.url = "github:hyprwm/Hyprland";
  hyprland.url = "git+https://github.com/dguibert/Hyprland?ref=refs/heads/main&submodules=1";
  hyprland.inputs.nixpkgs.follows = "nixpkgs";
  hyprland.inputs.systems.follows = "systems";
  hyprland.inputs.pre-commit-hooks.follows = "git-hooks-nix";
  hyprsplit.url = "github:dguibert/hyprsplit";
  hyprsplit.inputs.hyprland.follows = "hyprland";

  hyprland-contrib = {
    url = "github:hyprwm/contrib";
    nixpkgs.follows = "nixpkgs";
  };

  #eww = {
  #  url = "github:elkowar/eww";
  #  nixpkgs.follows = "nur_packages";
  #  rust-overlay.follows = "rust-overlay";
  #};
  nix-ld.url = "github:Mic92/nix-ld";
  # this line assume that you also have nixpkgs as an input
  nix-ld.inputs.nixpkgs.follows = "nixpkgs";

  envfs.url = "github:Mic92/envfs";
  envfs.inputs.nixpkgs.follows = "nixpkgs";
  envfs.inputs.flake-parts.follows = "flake-parts";
  envfs.inputs.treefmt-nix.follows = "treefmt-nix";

  nixos-wsl.url = "github:nix-community/NixOS-WSL";
  nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  nixos-wsl.inputs.flake-compat.follows = "flake-compat";

  impermanence.url = "github:nix-community/impermanence";
  impermanence.inputs.nixpkgs.follows = "nixpkgs";
  impermanence.inputs.home-manager.follows = "home-manager";
  #impermanence.url = "github:dguibert/impermanence";

  microvm.url = "github:astro/microvm.nix";
  microvm.inputs.nixpkgs.follows = "nixpkgs";

  nixos-hardware.url = "github:NixOS/nixos-hardware";

  #flake-parts.url = "github:hercules-ci/flake-parts";
  #flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  clan-core.url = "git+https://git.clan.lol/clan/clan-core";
  clan-core.inputs.sops-nix.follows = "sops-nix";
  clan-core.inputs.disko.follows = "disko";
  clan-core.inputs.treefmt-nix.follows = "treefmt-nix";
  clan-core.inputs.nixpkgs.follows = "nixpkgs/nixpkgs"; # Needed if your configuration uses nixpkgs unstable.
  clan-core.inputs.flake-parts.follows = "flake-parts";

  systems.follows = "clan-core/systems";

  treefmt-nix.url = "github:numtide/treefmt-nix";
  treefmt-nix.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  flake-compat.url = "github:edolstra/flake-compat";
  };

  nixConfig.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

##  outputs =
##    {
##      self,
##      flake-parts,
##      systems,
##      ...
##    }@inputs:
##    let
##      # Memoize nixpkgs for different platforms for efficiency.
##      inherit (self) outputs;
##      lib = inputs.nur_packages.lib;
##
##    in
##    flake-parts.lib.mkFlake { inherit inputs; } {
##      flake = {
##        overlays = import ./overlays {
##          inherit inputs;
##          lib = inputs.nur_packages.lib;
##        };
##
##        deploy.nodes = builtins.foldl' inputs.nur_packages.lib.recursiveUpdate { } [
##          (inputs.nur_packages.lib.mapAttrs
##            (
##              host: nixosConfig:
##              let
##                system = nixosConfig.config.nixpkgs.localSystem.system;
##              in
##              {
##                hostname = "${nixosConfig.config.networking.hostName}";
##                sshOpts = [
##                  "-o"
##                  "ControlMaster=no"
##                ]; # https://github.com/serokell/deploy-rs/issues/106
##                profilesOrder = [
##                  "system"
##                  "dguibert"
##                ];
##                profiles.system.path = self.legacyPackages.${system}.deploy-rs.lib.activate.nixos nixosConfig;
##                profiles.system.user = "root";
##                # Fast connection to the node. If this is true, copy the whole closure instead of letting the node substitute.
##                fastConnection = true;
##
##                # If the previous profile should be re-activated if activation fails.
##                autoRollback = true;
##
##                # See the earlier section about Magic Rollback for more information.
##                # This defaults to `true`
##                magicRollback = false;
##              }
##            )
##            (
##              builtins.removeAttrs self.nixosConfigurations [
##                "iso"
##                "iso-aarch64"
##              ]
##            )
##          )
##          # root profiles
##          (inputs.nur_packages.lib.mapAttrs
##            (
##              host: homeConfig:
##              let
##                system = self.nixosConfigurations.${host}.config.nixpkgs.localSystem.system;
##              in
##              {
##                #profiles.root.path = inputs.deploy-rs.lib.aarch64-linux.activate.custom
##                profiles.dguibert.path =
##                  self.legacyPackages.${system}.deploy-rs.lib.activate.custom homeConfig.activationPackage
##                    "./activate";
##                profiles.dguibert.user = "root";
##              }
##            )
##            {
##              rpi02 = self.homeConfigurations."root@rpi02";
##              rpi31 = self.homeConfigurations."root@rpi31";
##              rpi41 = self.homeConfigurations."root@rpi41";
##              titan = self.homeConfigurations."root@titan";
##              t580 = self.homeConfigurations."root@t580";
##            }
##          )
##          (
##            let
##              genProfile = user: name: profile: {
##                path =
##                  self.legacyPackages.x86_64-linux.deploy-rs.lib.activate.custom
##                    self.homeConfigurations."${name}".activationPackage
##                    ''
##                      export NIX_STATE_DIR=${self.homeConfigurations."${name}".config.home.sessionVariables.NIX_STATE_DIR}
##                      export NIX_PROFILE=${self.homeConfigurations."${name}".config.home.sessionVariables.NIX_PROFILE}
##                      ./activate
##                    '';
##                sshUser = user;
##                profilePath = "${builtins.dirOf builtins.storeDir}/var/nix/profiles/per-user/${user}/${profile}";
##              };
##            in
##            {
##              spartan = {
##                hostname = "spartan";
##                sshOpts = [
##                  "-o"
##                  "ControlMaster=no"
##                ]; # https://github.com/serokell/deploy-rs/issues/106
##                fastConnection = true;
##                autoRollback = false;
##                magicRollback = false;
##
##                profiles.bguibertd = genProfile "bguibertd" "bguibertd@spartan" "hm";
##                profiles.bguibertd-x86_64 = genProfile "bguibertd" "bguibertd@spartan-x86_64" "hm-x86_64";
##                profiles.bguibertd-aarch64 = genProfile "bguibertd" "bguibertd@spartan-aarch64" "hm-aarch64";
##              };
##
##              mn5 = {
##                hostname = "mn5-nix";
##                fastConnection = true;
##                autoRollback = false;
##                magicRollback = false;
##
##                profiles.user = genProfile "evid356257" "evid356257@mn5" "hm";
##              };
##              param = {
##                hostname = "param";
##                fastConnection = true;
##                autoRollback = false;
##                magicRollback = false;
##
##                profiles.user = genProfile "gdavid" "gdavid@param" "hm";
##              };
##              #levante = {
##              #  hostname = "levante";
##              #  sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
##              #  fastConnection = true;
##              #  autoRollback = false;
##              #  magicRollback = false;
##
##              #  profiles.dguibert = genProfile "b381115" "dguibert@levante" "hm";
##
##              #};
##              #lumi = {
##              #  hostname = "lumi";
##              #  sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
##              #  fastConnection = true;
##              #  autoRollback = false;
##              #  magicRollback = false;
##
##              #  profiles.dguibert = genProfile "dguibert" "dguibert@lumi" "hm";
##
##              #};
##            }
##          )
##
##          ({ })
##        ];
##
##      };
##      systems = [
##        "x86_64-linux"
##        "aarch64-linux"
##      ];
##      imports = [
##        inputs.clan-core.flakeModules.default
##        #./home/profiles
##        ./homes
##        ./hosts
##        ./modules/all-modules.nix
##        ./apps
##        ./checks
##        ./shells
##      ];
##      # Usage see: https://docs.clan.lol
##      clan = {
##        # Ensure this is unique among all clans you want to use.
##        meta.name = "orsin-homelab";
##
##        pkgsForSystem = system: builtins.trace "pkgsForSystem.${system}" self.legacyPackages.${system};
##
##        specialArgs = {
##          inherit inputs;
##          self' = self;
##          pkgsForSystem =
##            system: builtins.trace "specialArgs.pkgsForSystem.${system}" self.legacyPackages.${system};
##        };
##
##        inventory.machines.titan.tags = [
##          "desktop"
##          "dguibert"
##        ];
##        inventory.machines.t580.tags = [
##          "desktop"
##          "dguibert"
##          "wifi"
##        ];
##        inventory.machines.rpi41.tags = [
##          "desktop64"
##          "dguibert_rpi"
##          "wifi"
##        ];
##        inventory.machines.rpi31.tags = [
##          "wifi"
##          "dguibert_rpi"
##        ];
##        inventory.machines.rpi02.tags = [
##          "wifi"
##          "dguibert_rpi"
##        ];
##
##        inventory.modules = self.modules.clan;
##
##        modules = self.modules.clan-services;
##
##        inventory.instances = {
##          _3d_printing = {
##            module.input = "self";
##            roles.voron02_1.machines.rpi02 = { };
##          };
##
##          haproxy = {
##            module.input = "self";
##            roles.default.machines.rpi41 = { };
##          };
##
##          home-manager = {
##            module.input = "self";
##
##            roles.dguibert.tags.dguibert = { };
##            roles.dguibert-emacs.tags.dguibert = { };
##            roles.dguibert-gui.tags.desktop = { };
##            roles.dguibert-annex.tags.dguibert = { };
##            roles.dguibert-persistence.tags.dguibert = { };
##            roles.dguibert-mail.machines.titan = { };
##            roles.dguibert-3d-tools.machines.titan = { };
##            roles.dguibert-ssh-teleport.machines.titan = { };
##            roles.dguibert.machines.titan.settings.centralMailHost.enable = true;
##            roles.dguibert-vscode.machines.titan = { };
##
##            #roles.dguibert.tags.dguibert_rpi.settings = {
##            roles.dguibert.machines.titan.settings.withPersistence.enable = true;
##            roles.dguibert.machines.t580.settings.withPersistence.enable = true;
##            roles.dguibert-gui.machines.rpi41.settings = {
##              hyprland.hyprsplit.enable = false;
##            };
##          };
##
##          jellyfin = {
##            module.input = "self";
##            roles.default.machines.titan = { };
##          };
##          libvirtd = {
##            module.input = "self";
##            roles.default.machines.titan = { };
##          };
##
##          my-sshd = {
##            module.input = "self";
##            roles.client.tags.all = { };
##            roles.client.settings = {
##              certificate.allowEmptyDomain = true;
##            };
##            roles.server.tags.all = { };
##            roles.server.settings = {
##              certificate.allowEmptyDomain = true;
##              certificate.searchDomains = [
##                "orsin.net"
##              ];
##            };
##            roles.server.machines.titan.settings.certificate.realms = [
##              "192.168.1.24"
##              "10.147.27.24"
##              "titan.home-vpn"
##            ];
##            roles.server.machines.t580.settings.certificate.realms = [
##              "192.168.1.17"
##              "10.147.27.17"
##              "t580.home-vpn"
##            ];
##            roles.server.machines.rpi02.settings.certificate.realms = [
##              "192.168.1.12"
##              "10.147.27.12"
##              "rpi02.home-vpn"
##            ];
##            roles.server.machines.rpi31.settings.certificate.realms = [
##              "192.168.1.13"
##              "10.147.27.13"
##              "rpi31.home-vpn"
##            ];
##            roles.server.machines.rpi41.settings.certificate.realms = [
##              "192.168.1.14"
##              "10.147.27.14"
##              "82.64.121.168"
##              "rpi41.home-vpn"
##            ];
##          };
##          ollama = {
##            module.input = "self";
##            #roles.default.machines.titan = { };
##          };
##          seedbox = {
##            module.input = "self";
##            roles.qbittorrent.machines.titan = { };
##            roles.rtorrent.machines.titan = { };
##          };
##          printing = {
##            module.input = "self";
##            roles.scan2host.machines.titan = { };
##            roles.default.machines.titan = { };
##            roles.default.machines.t580 = { };
##          };
##          rkvm = {
##            module.input = "self";
##            roles.server.machines.titan = { };
##            roles.client.machines.rpi41 = { };
##            roles.server.settings.rkvm.server = "192.168.1.24"; # TODO get from server ip
##            roles.client.settings.rkvm.server = "192.168.1.24";
##          };
##
##          sshguard = {
##            module.input = "self";
##            roles.default.tags.all = { };
##          };
##          tiny-ca = {
##            module.input = "self";
##            roles.server.machines.titan = { };
##          };
##          totp-authentication = {
##            module.input = "self";
##            roles.default.tags.all = { };
##            roles.default.settings.users.dguibert.prompt = true;
##          };
##
##          users = {
##            module.input = "self";
##            roles.default.tags.all = { };
##            roles.default.settings.passwords.root.prompt = true;
##            roles.default.settings.passwords.dguibert.prompt = true;
##          };
##
##          wayland = {
##            module.input = "self";
##            roles.default.tags.desktop = { };
##            #roles.default.tags.desktop64.settings = {
##            roles.default.machines.rpi41.settings = {
##              enable32Bit = false;
##            };
##          };
##
##          yubikey = {
##            module.input = "self";
##            roles.default.tags.desktop = { };
##          };
##
##          zigbee = {
##            module.name = "zigbee";
##            module.input = "self";
##            roles.server.machines.rpi41 = { };
##          };
##
##          iwd = {
##            module.input = "self";
##            roles.default.tags.wifi = { };
##            roles.default.settings = {
##              networks = {
##                Freebox-AD070E = { };
##                Livebox-765e = { };
##                Livebox-D854 = { };
##                Livebox-D540 = { };
##                OPTUS_ACCB7F = {
##                  Hidden = true;
##                };
##              };
##            };
##          };
##          #  mopidy = {
##          #  module.name = "mopidy";
##          #  roles.default.machines.titan = { }; # TODO migrate mopidy to pipewire
##          #};
##          microvm = {
##            module.input = "self";
##            roles.default.machines.titan = { };
##          };
##
##          openvpn-cdac = {
##            module.input = "self";
##            roles.default.machines.titan = { };
##          };
##
##          home-vpn = {
##            # TODO add networking.wireguard.useNetworkd = true; # (defined in default.nix)
##            module.name = "wireguard";
##            module.input = "clan-core";
##            roles.controller.machines.rpi41.settings = {
##              endpoint = "82.64.121.168";
##              port = 51820; # default UDP port
##            };
##            roles.peer.machines = {
##              titan.settings.controller = "rpi41";
##              t580 = { };
##              rpi02 = { };
##              rpi31 = { };
##            };
##          };
##
##          distributed-build = {
##            module.input = "self";
##            roles.server.machines.rpi41 = { };
##            roles.client.tags.all = { };
##          };
##        };
##
##        # Prerequisite: boot into the installer.
##        # All machines in the ./machines will be imported.
##        # See: https://docs.clan.lol/getting-started/installer
##        # local> mkdir -p ./machines/machine1
##        # local> Edit ./machines/<machine>/configuration.nix to your liking.
##      };
##
##      perSystem =
##        {
##          config,
##          self',
##          inputs',
##          pkgs,
##          system,
##          ...
##        }:
##        {
##          # This is highly advised, and will prevent many possible mistakes
##          checks = (self.legacyPackages.${system}.deploy-rs.lib.deployChecks inputs.self.deploy);
##
##        };
##    };

}
