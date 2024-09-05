{ self, config, pkgs, lib, inputs, perSystem, system, ... }:
let
  config' = config;
  overlays = [
    self.overlays.default
    inputs.deploy-rs.overlay
    inputs.nxsession.overlay
    #inputs.nixpkgs-wayland.overlay
    inputs.hyprland.overlays.default
    # for rpi31
    (final: prev: {
      makeModulesClosure = { kernel, firmware, rootModules, allowMissing ? false }: prev.makeModulesClosure
        {
          inherit kernel firmware rootModules;
          allowMissing = true;
        };
    })
  ];

  packages = config:
    if config'.user_config.nixpkgs_with_custom_stdenv or false
    then
    # packages with overriden stdenv
      system: builtins.trace "use of nixpkgs_with_custom_stdenv" inputs.nixpkgs_with_stdenv.legacyPackages.${system}.appendOverlays overlays
    else
      system: inputs.nur_packages.legacyPackages.${system}.appendOverlays overlays
  ;
in
{
  config._module.args.pkgs = packages config system;

  config.perSystem = { config, self', inputs', pkgs, system, ... }: {
    _module.args.pkgs = packages config system;
    legacyPackages = packages config system;
  };
}
