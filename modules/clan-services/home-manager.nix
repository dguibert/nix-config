{
  _class = "clan.service";
  manifest.name = "home-manager";

  roles.dguibert = {
    interface =
      { lib, ... }:
      {
        options = {
          withGui.enable = (lib.mkEnableOption "Host running with X11 or Wayland") // {
            default = false;
          };
          withPersistence.enable = lib.mkEnableOption "Use Impermanence";
          centralMailHost.enable = lib.mkEnableOption "Host running liier/mbsync" // {
            default = false;
          };
          withBash.enable = (lib.mkEnableOption "Enable bash config") // {
            default = true;
          };
          withBash.history-merge = (lib.mkEnableOption "Enable bash history merging") // {
            default = true;
          };
          withGpg.enable = (lib.mkEnableOption "Enable GPG config") // {
            default = true;
          };
          withNix.enable = (lib.mkEnableOption "Enable nix config") // {
            default = true;
          };
          withZellij.enable = (lib.mkEnableOption "Enable Zellij config"); # // { default = true; };
          withVSCode.enable = (lib.mkEnableOption "Enable VSCode config"); # // { default = true; };
        };
      };

    perInstance =
      {
        instanceName,
        settings,
        machine,
        roles,
        ...
      }:
      {
        nixosModule =
          { config, pkgs, ... }:
          {
            home-manager.extraSpecialArgs = {
              inherit pkgs;
            };
            home-manager.users.dguibert = {
              imports = [
                (
                  { config, pkgs, ... }:
                  {
                    home.homeDirectory = "/home/dguibert";
                    home.stateVersion = "23.05";

                    programs.direnv.enable = true;
                    programs.direnv.nix-direnv.enable = true;
                    home.packages = with pkgs; [
                      pass-git-helper
                    ];
                  }
                )
                ../home-manager/dguibert.nix
                {
                  withGui.enable = settings.withGui.enable;
                  withPersistence.enable = settings.withPersistence.enable;
                  centralMailHost.enable = settings.centralMailHost.enable;
                  withBash.enable = settings.withBash.enable;
                  withBash.history-merge = settings.withBash.history-merge;
                  withGpg.enable = settings.withGpg.enable;
                  withNix.enable = settings.withNix.enable;
                  withZellij.enable = settings.withZellij.enable;
                  withVSCode.enable = settings.withVSCode.enable;
                }
              ];
            };
          };
      };
  };

  roles.dguibert-emacs.perInstance =
    { ... }:
    {
      nixosModule =
        { config, pkgs, ... }:
        {
          home-manager.users.dguibert = {
            imports = [
              ../home-manager/dguibert/emacs.nix
              {
                withEmacs.enable = true;
              }
            ];
          };
        };

    };

  perMachine =
    {
      instances,
      settings,
      machine,
      roles,
      ...
    }:
    {
      nixosModule =
        {
          config,
          lib,
          pkgs,
          inputs,
          ...
        }:
        {
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.extraSpecialArgs = {
            inherit inputs pkgs;
            sopsDecrypt_ = pkgs.sopsDecrypt_;
          };
        };
    };
}
