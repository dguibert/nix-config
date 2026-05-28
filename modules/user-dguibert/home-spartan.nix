{
  config,
  pkgs,
  lib,
  ...
}:
{

  flake.deploy.nodes.spartan = {
    hostname = "spartan";
    fastConnection = true;
    autoRollback = false;
    magicRollback = false;

    profiles.bguibertd = config.flake.lib.genProfile "bguibertd" "bguibertd@spartan" "hm";
    profiles.bguibertd-x86_64 =
      config.flake.lib.genProfile "bguibertd" "bguibertd@spartan-x86_64"
        "hm-x86_64";
    profiles.bguibertd-aarch64 =
      config.flake.lib.genProfile "bguibertd" "bguibertd@spartan-aarch64"
        "hm-aarch64";
  };

  configurations.home."bguibertd@spartan".system = "x86_64-linux";
  configurations.home."bguibertd@spartan".module =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.homeManager.custom_stdenv
        config.flake.modules.homeManager.dguibert
        config.flake.modules.homeManager.dguibert-bash
        config.flake.modules.homeManager.dguibert-custom-profile
      ];
      home.username = "bguibertd";
      home.homeDirectory = "/home_nfs/users/bguibertd";
      home.stateVersion = "25.11";

      withCustomProfile.enable = true;
      withCustomProfile.suffix = "";

      programs.bash.enable = true;
      programs.bash.historySize = -1; # no truncation
      programs.bash.historyFile = "$HOME/.bash_history";
      programs.bash.historyFileSize = -1; # no truncation
      programs.bash.historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      programs.bash.historyIgnore = [
        "ls"
        "cd"
        "clear"
        "[bf]g"
        " *"
        "cd -"
        "history"
        "history -*"
        "pwd"
        "exit"
        "date"
      ];

      programs.bash.bashrcExtra = # (homes.withoutX11 args).programs.bash.initExtra +
        ''
          # support for x86_64/aarch64
          # include .bashrc if it exists
          [[ -f ~/.bashrc.$(uname -m) ]] && . ~/.bashrc.$(uname -m)
        '';
      programs.bash.profileExtra = ''
        # support for x86_64/aarch64
        # include .profile if it exists
        [[ -f ~/.profile.$(uname -m) ]] && . ~/.profile.$(uname -m)
      '';
      home.sessionVariables.NIX_SSL_CERT_FILE = "/etc/pki/tls/certs/ca-bundle.crt";
      home.sessionVariables.TMP = "/dev/shm";

    };

  configurations.home."bguibertd@spartan-x86_64".system = "x86_64-linux";
  configurations.home."bguibertd@spartan-x86_64".module =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.homeManager.custom_stdenv
        config.flake.modules.homeManager.dguibert
        config.flake.modules.homeManager.dguibert-bash
        config.flake.modules.homeManager.dguibert-emacs
        config.flake.modules.homeManager.dguibert-zellij
        config.flake.modules.homeManager.dguibert-custom-profile
        config.flake.modules.homeManager.dguibert-annex
      ];
      home.username = "bguibertd";
      home.homeDirectory = "/home_nfs/users/bguibertd";
      home.stateVersion = "22.11";
      home.packages = with pkgs; [
        nix
        nix-output-monitor
        xpra
        bashInteractive

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
    };

  configurations.home."bguibertd@spartan-aarch64".system = "aarch64-multiplatform";
  configurations.home."bguibertd@spartan-aarch64".crossCompilation = true;
  configurations.home."bguibertd@spartan-aarch64".module =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        config.flake.modules.homeManager.custom_stdenv
        config.flake.modules.homeManager.dguibert
        config.flake.modules.homeManager.dguibert-bash
        config.flake.modules.homeManager.dguibert-custom-profile
      ];
      withCustomProfile.enable = true;
      withCustomProfile.suffix = "aarch64";
      home.username = "bguibertd";
      home.homeDirectory = "/home_nfs/users/bguibertd";
      home.stateVersion = "25.11";

      _module.args.activationPkgs = pkgs.buildPackages;
      home.packages = with pkgs; [
        bashInteractive
        nix
      ];
    };
}
