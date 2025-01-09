{ config
, lib
, inputs
, outputs
, pkgsForSystem
, ...
}@args:
with lib;
let
  cfg = config.clan.home-manager.dguibert;
  pkgs = pkgsForSystem config.nixpkgs.system;
in
{
  imports = [
    ../common.nix
    ({
      home-manager.extraSpecialArgs = {
        config' = cfg;
        inherit pkgs;
      };
      home-manager.users.dguibert = {
        imports = [
          ({ config, pkgs, ... }: {
            home.homeDirectory = "/home/dguibert";
            home.stateVersion = "23.05";

            programs.direnv.enable = true;
            programs.direnv.nix-direnv.enable = true;
            home.packages = with pkgs; [
              pass-git-helper
            ];
          })
        ];
      };
    })
  ];
  options.clan.home-manager.dguibert = {
    withGui.enable = (mkEnableOption "Host running with X11 or Wayland") // { default = false; };
    withPersistence.enable = mkEnableOption "Use Impermanence";
    centralMailHost.enable = mkEnableOption "Host running liier/mbsync" // { default = false; };
    withBash.enable = (lib.mkEnableOption "Enable bash config") // { default = true; };
    withBash.history-merge = (lib.mkEnableOption "Enable bash history merging") // { default = true; };
    withGpg.enable = (lib.mkEnableOption "Enable GPG config") // { default = true; };
    withNix.enable = (lib.mkEnableOption "Enable nix config") // { default = true; };
    withZellij.enable = (lib.mkEnableOption "Enable Zellij config"); # // { default = true; };
    withVSCode.enable = (lib.mkEnableOption "Enable VSCode config"); # // { default = true; };
  };

  config = {
    home-manager.users.dguibert = {
      imports = [
        ../../../home-manager/dguibert.nix
        {
          withBash.enable = cfg.withBash.enable;
          withBash.history-merge = cfg.withBash.history-merge;
          withGpg.enable = cfg.withGpg.enable;
          withNix.enable = cfg.withNix.enable;
          withZellij.enable = cfg.withZellij.enable;
          withVSCode.enable = cfg.withVSCode.enable;
        }
      ];
    };
  };
}
