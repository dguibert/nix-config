{
  self,
  config,
  pkgs,
  lib,
  inputs,
  withSystem,
  ...
}:
let
  inherit (lib) concatMapStrings concatMapStringsSep head;
in
{
  config.configurations.nixos.iso-aarch64.module = {
    imports = [ config.configurations.nixos.iso.module ];
    #nixpkgs.localSystem.system = lib.mkForce "aarch64-linux";
    nixpkgs.hostPlatform.system = "aarch64-linux";
  };
}
