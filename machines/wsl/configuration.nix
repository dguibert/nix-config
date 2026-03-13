{
  config,
  lib,
  inputs,
  withSystem,
  self,
  ...
}:
{
  imports = [
    { nixpkgs.system = "x86_64-linux"; }
    inputs.nixos-wsl.nixosModules.wsl
    ../../modules/nixos/defaults
  ];
  wsl.enable = true;
  wsl.defaultUser = "dguibert";
  wsl.startMenuLaunchers = true;

}
