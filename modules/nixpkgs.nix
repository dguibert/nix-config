{
  config,
  lib,
  inputs,
  perSystem,
  withSystem,
  ...
}:
let
  overlays = [
    #self.overlays.default
    inputs.deploy-rs.overlays.default
    inputs.nxsession.overlay
    inputs.nur_packages.inputs.emacs-overlay.overlay
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
      inherit system overlays;
      config = nixpkgs_config;
    };
in
{
  flake-file.inputs = {
    nixpkgs.url = "github:dguibert/nixpkgs/pu";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nur_packages.url = "github:dguibert/nur-packages?ref=master";

    nxsession.url = "github:dguibert/nxsession";
    # For accessing `deploy-rs`'s utility Nix functions
    deploy-rs.url = "github:dguibert/deploy-rs/pu";
  };

  _module.args.pkgs = builtins.trace "pkgs" packages (builtins.currentSystem or "x86_64-linux");
  #  config._module.args.pkgs = packages config system;
  # https://flake.parts/system
  flake.aspects.nixpkgs.nixos = {
    nixpkgs.config = nixpkgs_config;
    nixpkgs.overlays = overlays;
  };

  flake.aspects.nixpkgs.homeManager = {
    nixpkgs.config = nixpkgs_config;
    nixpkgs.overlays = overlays;
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
      _module.args.pkgs = packages system;
      legacyPackages = packages system;
    };
}
