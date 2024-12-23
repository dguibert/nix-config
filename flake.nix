{
  description = "Configurations of my systems";

  inputs.config_json.url = "github:dguibert/nix-config?dir=configs/default";
  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs.home-manager.url = "github:dguibert/home-manager/pu";
  inputs.home-manager.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  inputs.hydra.url = "github:dguibert/hydra/pu";
  inputs.hydra.inputs.nix.follows = "nix";
  inputs.hydra.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  inputs.nix.follows = "nur_packages/nix";

  inputs.nur.url = "github:nix-community/NUR";
  inputs.sops-nix.url = "github:dguibert/sops-nix/pu"; # for dg/use-with-cross-system
  inputs.sops-nix.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  inputs.upstream_nixpkgs.url = "github:dguibert/nixpkgs/pu";
  inputs.nur_packages.url = "github:dguibert/nur-packages?refs=master";
  inputs.nur_packages.inputs.nixpkgs.follows = "upstream_nixpkgs";
  inputs.nixpkgs_with_stdenv.url = "github:dguibert/nix-config?dir=nixpkgs";
  inputs.nixpkgs_with_stdenv.inputs.nixpkgs.follows = "nur_packages";

  inputs.disko.url = "github:nix-community/disko";
  #inputs.disko.url = github:dguibert/disko;
  inputs.disko.inputs.nixpkgs.follows = "nur_packages";

  inputs.terranix = { url = "github:mrVanDalo/terranix"; flake = false; };
  #inputs."nixos-18.03".url   = "github:nixos/nixpkgs-channels/nixos-18.03";
  #inputs."nixos-18.09".url   = "github:nixos/nixpkgs-channels/nixos-18.09";
  #inputs."nixos-19.03".url   = "github:nixos/nixpkgs-channels/nixos-19.03";
  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nur_packages";
  inputs.stylix.inputs.home-manager.follows = "home-manager";
  inputs.stylix.inputs.base16.follows = "base16";
  inputs.stylix.inputs.base16-vim.follows = "base16-vim";

  inputs.base16.url = "github:SenchoPens/base16.nix";
  #inputs.base16.inputs.nixpkgs.follows = "nur_packages";
  inputs.tt-schemes = { url = "github:tinted-theming/schemes"; flake = false; };
  inputs.base16-vim = { url = "github:tinted-theming/base16-vim"; flake = false; };
  inputs.base16-shell = { url = "github:tinted-theming/tinted-shell"; flake = false; };
  inputs.gitignore = { url = "github:hercules-ci/gitignore"; flake = false; };

  inputs.nxsession.url = "github:dguibert/nxsession";
  inputs.nxsession.inputs.nixpkgs.follows = "nur_packages/nixpkgs";
  inputs.nxsession.inputs.flake-utils.follows = "nur_packages/flake-utils";

  # For accessing `deploy-rs`'s utility Nix functions
  inputs.deploy-rs.url = "github:dguibert/deploy-rs/pu";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  #inputs.nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
  # only needed if you use as a package set:
  #inputs.nixpkgs-wayland.inputs.nixpkgs.follows = "nur_packages";
  #inputs.nixpkgs-wayland.inputs.master.follows = "master";
  #inputs.emacs-overlay.url = "github:nix-community/emacs-overlay";
  inputs.emacs-overlay.follows = "nur_packages/emacs-overlay";

  inputs.flake-parts.follows = "nur_packages/flake-parts";
  inputs.flake-utils.follows = "nur_packages/flake-utils";

  inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";
  inputs.git-hooks-nix.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  #inputs.hyprland.url = "github:hyprwm/Hyprland";
  #inputs.hyprland.url = "git+https://github.com/dguibert/Hyprland?submodules=1";
  inputs.hyprland.url = "github:dguibert/Hyprland?ref=refs/heads/main&submodules=1";
  inputs.hyprland.inputs.nixpkgs.follows = "nur_packages";
  inputs.hyprsplit.url = "github:dguibert/hyprsplit";
  inputs.hyprsplit.inputs.hyprland.follows = "hyprland";

  inputs.hyprland-contrib = {
    url = "github:hyprwm/contrib";
    inputs.nixpkgs.follows = "nur_packages";
  };


  #inputs.eww = {
  #  url = "github:elkowar/eww";
  #  inputs.nixpkgs.follows = "nur_packages";
  #  inputs.rust-overlay.follows = "rust-overlay";
  #};
  inputs.nix-ld.url = "github:Mic92/nix-ld";
  # this line assume that you also have nixpkgs as an input
  inputs.nix-ld.inputs.nixpkgs.follows = "nur_packages";

  inputs.envfs.url = "github:Mic92/envfs";
  inputs.envfs.inputs.nixpkgs.follows = "nur_packages";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nur_packages";
  inputs.nixos-wsl.inputs.flake-utils.follows = "nur_packages/flake-utils";

  #inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.url = "github:dguibert/impermanence";

  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nur_packages";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  nixConfig.extra-experimental-features = [ "nix-command" "flakes" ];

  outputs = { self, flake-parts, ... }@inputs:
    let
      # Memoize nixpkgs for different platforms for efficiency.
      inherit (self) outputs;
      lib = inputs.nur_packages.lib;

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        overlays = import ./overlays { inherit inputs; lib = inputs.nur_packages.lib; };

        deploy.nodes = builtins.foldl' inputs.nur_packages.lib.recursiveUpdate { } [
          (inputs.nur_packages.lib.mapAttrs
            (host: nixosConfig:
              let
                system = nixosConfig.config.nixpkgs.localSystem.system;
              in
              {
                hostname = "${nixosConfig.config.networking.hostName}";
                sshOpts = [ "-o" "ControlMaster=no" ]; # https://github.com/serokell/deploy-rs/issues/106
                profilesOrder = [ "system" "dguibert" ];
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
            (builtins.removeAttrs self.nixosConfigurations [ "iso" "iso-aarch64" ]))
          # root profiles
          (inputs.nur_packages.lib.mapAttrs
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
          (inputs.nur_packages.lib.mapAttrs
            (host: homeConfig:
              let
                system = self.nixosConfigurations.${host}.config.nixpkgs.localSystem.system;
              in
              {
                #profiles.root.path = inputs.deploy-rs.lib.aarch64-linux.activate.custom
                profiles.dguibert.path = self.legacyPackages.${system}.deploy-rs.lib.activate.custom homeConfig.activationPackage ''
                  export HOME_MANAGER_BACKUP_EXT=backup
                  ./activate
                '';
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
        inputs.config_json.flakeModule.user_config_settings
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
