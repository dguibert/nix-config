{
  inputs,
  config,
  ...
}:
{
  flake-file.inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.flake-compat.follows = "flake-compat";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  configurations.nixos.wsl.module = {
    imports = [
      inputs.nixos-wsl.nixosModules.wsl
      inputs.sops-nix.nixosModules.sops
      ({
        nixpkgs.hostPlatform.system = "x86_64-linux";
        wsl.enable = true;
        wsl.defaultUser = "dguibert";
        wsl.startMenuLaunchers = true;

        #programs.bash.loginShellInit = "nixos-wsl-welcome";
      })
      (
        { pkgs, ... }:
        {
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
      config.flake.modules.nixos.cacerts
      config.flake.modules.nixos.dns
      config.flake.modules.nixos.fr
      config.flake.modules.nixos.nix
      config.flake.modules.nixos.nix-registry
      config.flake.modules.nixos.sshd
      config.flake.modules.nixos.nixpkgs
      config.flake.modules.nixos.report-changes


      config.flake.modules.nixos.user-root

      config.flake.modules.nixos.dguibert
      config.flake.modules.nixos.dguibert-bash
      config.flake.modules.nixos.dguibert-emacs
      config.flake.modules.nixos.dguibert-stylix
      { home-manager.users.dguibert.withEmacs.enable = true; }
      config.flake.modules.nixos.dguibert-foot
      config.flake.modules.nixos.dguibert-git
      config.flake.modules.nixos.dguibert-gpg
      config.flake.modules.nixos.dguibert-htop
      config.flake.modules.nixos.dguibert-ssh
      config.flake.modules.nixos.dguibert-tmux
      #config.flake.modules.nixos.dguibert-annex
      config.flake.modules.nixos.dguibert-zellij
      {  home-manager.users.dguibert.dconf.enable = false; } # dbus: Failed to start message bus:
    ];
  };
}
