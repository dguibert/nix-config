{
  self,
  lib,
  inputs,
  ...
}:
{
  flake.lib =
    let
      l = lib // builtins;
    in
    inputs.nur_packages.lib
    // {
      genHomeManagerConfiguration = import ../../lib/gen-home-manager-configuration.nix { inherit lib; };
    };
}
