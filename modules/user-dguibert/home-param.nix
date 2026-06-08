{
  config,
  pkgs,
  lib,
  ...
}:
{

  flake.deploy.nodes."gdavid@param-rudra" = {
    hostname = "param(rudra";
    fastConnection = true;
    autoRollback = false;
    magicRollback = false;

    profiles.user = config.flake.lib.genProfile "gdavid" "gdavid@param-rudra" "hm";
  };

  configurations.home."gdavid@param-rudra".system = "x86_64-linux";
  configurations.home."gdavid@param-rudra".module =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.homeManager.custom_stdenv
        config.flake.modules.homeManager.dguibert
        config.flake.modules.homeManager.dguibert-bash
        config.flake.modules.homeManager.dguibert-custom-profile
        config.flake.modules.homeManager.dguibert-emacs
        config.flake.modules.homeManager.dguibert-foot
        config.flake.modules.homeManager.dguibert-git
        config.flake.modules.homeManager.dguibert-gpg
        config.flake.modules.homeManager.dguibert-htop
        config.flake.modules.homeManager.dguibert-ssh
        #config.flake.modules.homeManager.dguibert-tmux
        config.flake.modules.homeManager.dguibert-zellij
        config.flake.modules.homeManager.dguibert-annex
      ];
      home.username = "gdavid";
      home.homeDirectory = "/home/gdavid";
      home.stateVersion = "26.05";

      withCustomProfile.enable = true;
      withCustomProfile.suffix = "";

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

      home.packages = with pkgs; [
        nix
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
      ];

      home.sessionVariables.NIX_SSL_CERT_FILE = "/etc/pki/tls/certs/ca-bundle.crt";
      home.sessionVariables.TMP = "/dev/shm";

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
    };
}
