{
  config,
  lib,
  inputs,
  ...
}:
let
  overlays = [
    #self.overlays.default
    inputs.deploy-rs.overlays.default
    inputs.nxsession.overlay
    inputs.nur_packages.inputs.emacs-overlay.overlay
    inputs.nur_packages.overlays.default
    inputs.nur_packages.overlays.extra-builtins
    inputs.nur_packages.overlays.emacs
    #inputs.nixpkgs-wayland.overlay
    #inputs.hyprland.overlays.default
  ]
  ++ (builtins.attrValues config.flake.overlays);

  nixpkgs_config = {
    allowUnfree = true;
  };

  #packages = system: inputs.nixpkgs.legacyPackages.${system}.appendOverlays overlays;
  packages =
    system:
    import inputs.nixpkgs {
      localSystem.system = system;
      overlays = config.pkgs.overlays;
      config = config.pkgs.config;
    };
in
{
  options.pkgs = {
    config = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = {
        allowUnfree = true;
      };
    };
    overlays = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };
  };

  config = {
    flake-file.inputs = {
      nixpkgs.url = "github:dguibert/nixpkgs/pu";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
      nur_packages.url = "github:dguibert/nur-packages?ref=master";

      nxsession.url = "github:dguibert/nxsession";
      nxsession.inputs.nixpkgs.follows = "nixpkgs";
      nxsession.inputs.flake-utils.follows = "flake-utils";
      # For accessing `deploy-rs`'s utility Nix functions
      deploy-rs.url = "github:dguibert/deploy-rs/pu";
      deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    };

    pkgs.config = nixpkgs_config;
    pkgs.overlays = overlays;

    _module.args.pkgs = builtins.trace "pkgs" packages (builtins.currentSystem or "x86_64-linux");
    #  config._module.args.pkgs = packages config system;
    # https://flake.parts/system
    flake.aspects.nixpkgs.flakeModule = {
      nixpkgs.config = config.pkgs.config;
      nixpkgs.overlays = config.pkgs.overlays;
    };

    flake.aspects.nixpkgs.nixos = {
      nixpkgs.config = config.pkgs.config;
      nixpkgs.overlays = config.pkgs.overlays;
    };

    flake.aspects.nixpkgs.homeManager = {
      nixpkgs.config = config.pkgs.config;
      nixpkgs.overlays = config.pkgs.overlays;
    };

    #flake.aspects.nixpkgs.nixos.imports = [
    #  inputs.nixpkgs.nixosModules.readOnlyPkgs
    #    ({ config, ... }: {
    #      # Use the configured pkgs from perSystem
    #      nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
    #        { pkgs, ... }: # perSystem module arguments
    #        pkgs
    #      );
    #    })
    #];

    perSystem =
      {
        system,
        config,
        ...
      }:
      {
        _module.args.pkgs = builtins.trace "pkgs in perSystem" packages system;
        legacyPackages = packages system;
      };
  };
}
