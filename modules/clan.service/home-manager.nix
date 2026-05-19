{
  flake.aspects.home-manager."clan.service" = {
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
                    home.stateVersion = "25.11";

                    programs.direnv.enable = true;
                    programs.direnv.nix-direnv.enable = true;
                    home.packages = with pkgs; [
                      pass-git-helper
                    ];
                  }
                )
                ../_home-manager/dguibert.nix
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
                ../_home-manager/dguibert/emacs.nix
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
            home-manager.users.dguibert = {
              imports = [
                #../home-manager/dguibert/impermanence.nix
                { withPersistence.enable = true; }
              ];
            };
          };
      };

    roles.dguibert-annex.perInstance =
      { ... }:
      {
        nixosModule =
          { config, pkgs, ... }:
          {
            home-manager.users.dguibert.withAnnex.enable = true;
          };

      };

    roles.dguibert-gui.interface =
      { lib, ... }:
      {
        options.hyprland.enable = (lib.mkEnableOption "Host running with hyprland") // {
          default = true;
        };
        options.hyprland.hyprsplit.enable =
          (lib.mkEnableOption "Host running with hyprsplit plugin on hyprland")
          // {
            default = true;
          };
      };

    roles.dguibert-gui.perInstance =
      { settings, ... }:
      {
        nixosModule =
          { config, pkgs, ... }:
          {
            home-manager.users.dguibert = {
              imports = [
                #../_home-manager/dguibert/with-gui.nix
                #../_home-manager/dguibert/module-hyprland.nix
                {
                  home.stateVersion = "25.11";
                  withGui.enable = true;
                  hyprland.enable = settings.hyprland.enable;
                  hyprland.hyprsplit.enable = settings.hyprland.hyprsplit.enable;
                }
              ];
            };
          };

      };

    roles.dguibert-vscode.perInstance =
      { settings, ... }:
      {
        nixosModule =
          { config, pkgs, ... }:
          {
            home-manager.users.dguibert.withVSCode.enable = true;
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

    roles.dguibert-ssh-teleport.perInstance =
      { ... }:
      {
        nixosModule =
          { config, pkgs, ... }:
          {
            home-manager.users.dguibert.ssh-teleport.enable = true;
          };

      };

    roles.dguibert-3d-tools.perInstance =
      { settings, ... }:
      {
        nixosModule =
          { config, pkgs, ... }:
          {
            home-manager.users.dguibert.with-3d-tools.enable = true;
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
            #- dguibert profile: xdg.portal: since you installed Home Manager via its NixOS module and
            #'home-manager.useUserPackages' is enabled, you need to add
            environment.pathsToLink = [
              "/share/applications"
              "/share/xdg-desktop-portal"
            ];

            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs pkgs;
              sopsDecrypt_ = pkgs.sopsDecrypt_;
            };
          };
      };
  };
}
