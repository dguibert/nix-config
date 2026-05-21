{
  inputs,
  config,
  ...
}:
{
  config.configurations.nixos.wsl.module = {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      ({
        nixpkgs.hostPlatform.system = "x86_64-linux";
        wsl.enable = true;
        wsl.defaultUser = "dguibert";
        wsl.startMenuLaunchers = true;

        #programs.bash.loginShellInit = "nixos-wsl-welcome";
      })
      inputs.impermanence.nixosModules.impermanence
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
        }
      )
      config.flake.modules.nixos.dns
      config.flake.modules.nixos.nix
      config.flake.modules.nixos.nix-registry

      config.flake.modules.nixos.user-root

      config.flake.modules.nixos.dguibert
      config.flake.modules.nixos.dguibert-bash
      config.flake.modules.nixos.dguibert-emacs
      config.flake.modules.nixos.dguibert-git
      config.flake.modules.nixos.dguibert-htop
      config.flake.modules.nixos.dguibert-ssh
      config.flake.modules.nixos.dguibert-zellij

    ];
  };
}
