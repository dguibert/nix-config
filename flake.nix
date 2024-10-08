{
  description = "Configurations of my systems";

  inputs.config_json.url = "path:configs/default/config.json";
  inputs.config_json.flake = false;
  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs.home-manager.url = "github:dguibert/home-manager/pu";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  inputs.hydra.url = "github:dguibert/hydra/pu";
  inputs.hydra.inputs.nix.follows = "nix";
  inputs.hydra.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  inputs.nix.follows = "nixpkgs/nix";

  inputs.nur.url = "github:nix-community/NUR";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  inputs.upstream_nixpkgs.url = "github:dguibert/nixpkgs/pu";
  inputs.nixpkgs.url = "github:dguibert/nur-packages?refs=master";
  inputs.nixpkgs.inputs.nixpkgs.follows = "upstream_nixpkgs";
  inputs.nixpkgs_with_stdenv.url = "path:nixpkgs";
  inputs.nixpkgs_with_stdenv.inputs.nixpkgs.follows = "nixpkgs";

  inputs.disko.url = github:nix-community/disko;
  #inputs.disko.url = github:dguibert/disko;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.terranix = { url = "github:mrVanDalo/terranix"; flake = false; };
  #inputs."nixos-18.03".url   = "github:nixos/nixpkgs-channels/nixos-18.03";
  #inputs."nixos-18.09".url   = "github:nixos/nixpkgs-channels/nixos-18.09";
  #inputs."nixos-19.03".url   = "github:nixos/nixpkgs-channels/nixos-19.03";
  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.home-manager.follows = "home-manager";
  inputs.stylix.inputs.base16.follows = "base16";
  inputs.stylix.inputs.base16-tmux.follows = "base16-tmux";
  inputs.stylix.inputs.base16-vim.follows = "base16-vim";

  inputs.base16.url = "github:SenchoPens/base16.nix";
  #inputs.base16.inputs.nixpkgs.follows = "nixpkgs";
  inputs.tt-schemes = { url = "github:tinted-theming/schemes"; flake = false; };
  inputs.base16-tmux = { url = github:tinted-theming/base16-tmux; flake = false; };
  inputs.base16-vim = { url = github:tinted-theming/base16-vim; flake = false; };
  inputs.base16-shell = { url = github:tinted-theming/tinted-shell; flake = false; };
  inputs.gitignore = { url = "github:hercules-ci/gitignore"; flake = false; };

  inputs.nxsession.url = "github:dguibert/nxsession";
  inputs.nxsession.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
  inputs.nxsession.inputs.flake-utils.follows = "nixpkgs/flake-utils";

  # For accessing `deploy-rs`'s utility Nix functions
  inputs.deploy-rs.url = "github:dguibert/deploy-rs/pu";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  #inputs.nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
  # only needed if you use as a package set:
  #inputs.nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
  #inputs.nixpkgs-wayland.inputs.master.follows = "master";
  #inputs.emacs-overlay.url = "github:nix-community/emacs-overlay";
  inputs.emacs-overlay.follows = "nixpkgs/emacs-overlay";

  inputs.flake-parts.follows = "nixpkgs/flake-parts";
  inputs.flake-utils.follows = "nixpkgs/flake-utils";

  inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";
  inputs.git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

  #inputs.hyprland.url = "github:hyprwm/Hyprland";
  #inputs.hyprland.url = "git+https://github.com/dguibert/Hyprland?submodules=1";
  inputs.hyprland.url = "git+https://github.com/dguibert/Hyprland?ref=refs/heads/main&submodules=1";
  inputs.hyprland.inputs.nixpkgs.follows = "nixpkgs";
  inputs.split-monitor-workspaces.url = "github:Duckonaut/split-monitor-workspaces";
  inputs.split-monitor-workspaces.inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended

  inputs.hyprland-contrib = {
    url = "github:hyprwm/contrib";
    inputs.nixpkgs.follows = "nixpkgs";
  };


  #inputs.eww = {
  #  url = "github:elkowar/eww";
  #  inputs.nixpkgs.follows = "nixpkgs";
  #  inputs.rust-overlay.follows = "rust-overlay";
  #};
  inputs.nix-ld.url = "github:Mic92/nix-ld";
  # this line assume that you also have nixpkgs as an input
  inputs.nix-ld.inputs.nixpkgs.follows = "nixpkgs";

  inputs.envfs.url = "github:Mic92/envfs";
  inputs.envfs.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-wsl.inputs.flake-utils.follows = "nixpkgs/flake-utils";

  inputs.impermanence.url = "github:nix-community/impermanence";

  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  nixConfig.extra-experimental-features = [ "nix-command" "flakes" ];

  outputs = { self, flake-parts, nixpkgs, ... }@inputs:
    let
      # Memoize nixpkgs for different platforms for efficiency.
      inherit (self) outputs;
      lib = nixpkgs.lib;

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        overlays = import ./overlays { inherit inputs; lib = inputs.nixpkgs.lib; };

        deploy.nodes = builtins.foldl' inputs.nixpkgs.lib.recursiveUpdate { } [
          (inputs.nixpkgs.lib.mapAttrs
            (host: nixosConfig:
              let
                system = nixosConfig.config.nixpkgs.localSystem.system;
              in
              {
                hostname = "${nixosConfig.config.networking.hostName}";
                sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
                profiles.system.path = self.legacyPackages.${system}.deploy-rs.lib.activate.nixos nixosConfig;
                profiles.system.user = "root";
                # Fast connection to the node. If this is true, copy the whole closure instead of letting the node substitute.
                fastConnection = true;

                # If the previous profile should be re-activated if activation fails.
                autoRollback = true;

                # See the earlier section about Magic Rollback for more information.
                # This defaults to `true`
                magicRollback = false;
              })
            (builtins.removeAttrs self.nixosConfigurations [ "iso" ]))
          # root profiles
          (inputs.nixpkgs.lib.mapAttrs
            (host: homeConfig:
              let
                system = self.nixosConfigurations.${host}.config.nixpkgs.localSystem.system;
              in
              {
                #profiles.root.path = inputs.deploy-rs.lib.aarch64-linux.activate.custom
                profiles.dguibert.path = self.legacyPackages.${system}.deploy-rs.lib.activate.custom homeConfig.activationPackage "./activate";
                profiles.dguibert.user = "root";
              })
            {
              rpi31 = self.homeConfigurations."root@rpi31";
              rpi41 = self.homeConfigurations."root@rpi41";
              titan = self.homeConfigurations."root@titan";
              t580 = self.homeConfigurations."root@t580";
            }
          )
          # dguibert profiles
          (inputs.nixpkgs.lib.mapAttrs
            (host: homeConfig:
              let
                system = self.nixosConfigurations.${host}.config.nixpkgs.localSystem.system;
              in
              {
                #profiles.root.path = inputs.deploy-rs.lib.aarch64-linux.activate.custom
                profiles.dguibert.path = self.legacyPackages.${system}.deploy-rs.lib.activate.custom homeConfig.activationPackage "./activate";
                profiles.dguibert.user = "dguibert";
              })
            {
              rpi31 = self.homeConfigurations."dguibert@rpi31";
              rpi41 = self.homeConfigurations."dguibert@rpi41";
              titan = self.homeConfigurations."dguibert@titan";
              t580 = self.homeConfigurations."dguibert@t580";
            }
          )
          (
            let
              genProfile = user: name: profile: {
                path = self.legacyPackages.x86_64-linux.deploy-rs.lib.activate.custom self.homeConfigurations."${name}".activationPackage ''
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
                sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
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
        #./home/profiles
        ./homes
        ./hosts
        ./modules/all-modules.nix
        ./apps
        ./checks
        ./shells
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # This is highly advised, and will prevent many possible mistakes
        checks = (self.legacyPackages.${system}.deploy-rs.lib.deployChecks inputs.self.deploy)
        ;

      };
    };

}
