{
  config,
  lib,
  inputs,
  withSystem,
  self,
  ...
}:
let
  genHomeManagerConfiguration = import ../lib/gen-home-manager-configuration.nix { inherit lib; };
in
{
  imports = [

    (genHomeManagerConfiguration "x86_64-linux" "bguibertd@spartan")
    (genHomeManagerConfiguration "x86_64-linux" "bguibertd@spartan-x86_64")
    #(genHomeManagerConfiguration "aarch64-linux" "bguibertd@spartan-aarch64")
    (genHomeManagerConfiguration "x86_64-linux" "bguibertd@spartan-aarch64")
  ];

  modules.homes."bguibertd@spartan-x86_64" = [
    (
      { config, pkgs, ... }:
      {
        imports = [
          ../modules/home-manager/dguibert.nix
          ../modules/home-manager/dguibert/custom-profile.nix
        ];
        centralMailHost.enable = false;
        withGui.enable = false;
        withZellij.enable = true;
        withCustomProfile.enable = true;
        withCustomProfile.suffix = "x86_64";
        withEmacs.enable = true;

        home.username = "bguibertd";
        home.homeDirectory = "/home_nfs/users/bguibertd";
        home.stateVersion = "22.11";

        home.packages = with pkgs; [
          nix
          nix-output-monitor
          xpra
          bashInteractive

          datalad
          git-annex
          git-nomad
          mr
          subversion

          tig
          python3
          python3Packages.pip

          nxsession

          figlet
          fdupes
          rdfind

          waypipe
          xwayland-satellite
        ];

        home.sessionVariables.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
        home.sessionVariables.COLORTERM = "truecolor";
        home.sessionVariables.TMP = "/dev/shm";

        programs.direnv.enable = true;
        programs.direnv.nix-direnv.enable = true;

        dconf.enable = false; # dbus: Failed to start message bus: Configuration file needs one or more <listen> elements giving addresses
      }
    )
  ];

  modules.homes."bguibertd@spartan-aarch64-cross-system" = "aarch64-multiplatform";
  modules.homes."bguibertd@spartan-aarch64" = [
    (
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        imports = [
          ../modules/home-manager/dguibert.nix
          ../modules/home-manager/dguibert/custom-profile.nix
        ];
        centralMailHost.enable = false;
        withGui.enable = false;
        withCustomProfile.enable = true;
        withCustomProfile.suffix = "aarch64";
        withEmacs.enable = false;
        withBash.history-merge = false;
        services.gpg-agent.enable = lib.mkForce false;
        withStylixTheme.enable = false; # -fromYAML- fails
        stylix.targets.gnome.enable = false;

        home.username = "bguibertd";
        home.homeDirectory = "/home_nfs/users/bguibertd";
        home.stateVersion = "22.11";

        _module.args.activationPkgs = pkgs.buildPackages;
        home.packages = with pkgs; [
          bashInteractive
          nix
        ];

        dconf.enable = false; # dbus: Failed to start message bus: Configuration file needs one or more <listen> elements giving addresses
      }
    )
  ];

}
