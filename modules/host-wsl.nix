{
  inputs,
  ...
}:
{
  config.configurations.nixos.iso.module = {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      ({
        nixpkgs.hostPlatform.system = "x86_64-linux";
        wsl.enable = true;
        wsl.defaultUser = "dguibert";
        wsl.startMenuLaunchers = true;

        #programs.bash.loginShellInit = "nixos-wsl-welcome";
      })
      ./_nixos/nix-conf.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.impermanence.nixosModules.impermanence
      ../users/dguibert
      (
        { pkgs, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          networking.resolvconf.enable = false; # environment.etc."resolv.conf" is also set
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

          i18n = {
            supportedLocales = [ "en_US.UTF-8/UTF-8" ];
          };

          home-manager.users.dguibert = {
            imports = [
              (
                { config, pkgs, ... }:
                {
                  imports = [
                    ../../modules/home-manager/dguibert.nix
                  ];
                  withGui.enable = false;
                  withEmacs.enable = true;
                  home.homeDirectory = "/home/dguibert";
                  home.stateVersion = "23.05";
                }
              )
            ];
          };
        }
      )

    ];
  };
}
