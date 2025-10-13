{
  _class = "clan.service";
  manifest.name = "home-manager";

  roles.dguibert.perInstance =
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
                withZellij.enable = true;
              }
            ];
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

  roles.dguibert-persistence.perInstance =
    { ... }:
    {
      nixosModule =
        { config, pkgs, ... }:
        {
          home-manager.users.dguibert.withPersistence.enable = true;
        };

    };

  roles.dguibert-gui.interface =
    { lib, ... }:
    {
      options.hyprland.hyprsplit.enable = lib.mkEnableOption "Host running with hyprsplit plugin on hyprland";
    };

  roles.dguibert-gui.perInstance =
    { settings, ... }:
    {
      nixosModule =
        { config, pkgs, ... }:
        {
          home-manager.users.dguibert.withGui.enable = true;
          home-manager.users.dguibert.hyprland.hyprsplit.enable = settings.hyprland.hyprsplit.enable;
        };

    };

  roles.dguibert-mail.perInstance =
    { ... }:
    {
      nixosModule =
        { config, pkgs, ... }:
        {
          home-manager.users.dguibert.centralMailHost.enable = true;
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
