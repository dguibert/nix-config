{ lib, config, ... }:
{
  flake.aspects.dguibert-empty.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-empty
  ];
  flake.aspects.dguibert-empty.homeManager =
    { pkgs, config, ... }:
    {
    };
}
