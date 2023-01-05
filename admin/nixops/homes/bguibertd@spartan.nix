{ lib, config, pkgs, inputs, outputs, ... }:
{
  imports = [
    ./dguibert/home.nix
    ./dguibert/emacs.nix
  ];
  centralMailHost.enable = false;
  withGui.enable = false;

  nixpkgs.overlays = [
    inputs.nur_dguibert.overlays.cluster
    inputs.nur_dguibert.overlays.store-spartan
  ];
  home.username = "bguibertd";
  home.homeDirectory = "/home_nfs/bguibertd";
  home.stateVersion = "22.11";
  #home.activation.setNixVariables = lib.hm.dag.entryBefore ["writeBoundary"]
  home.sessionVariables.NIX_STATE_DIR = "${pkgs.nixStore}/var/nix";
  home.sessionVariables.NIX_PROFILE = "${pkgs.nixStore}/var/nix/profiles/per-user/${config.home.username}/profile";
  programs.bash.bashrcExtra = /*(homes.withoutX11 args).programs.bash.initExtra +*/ ''
    export NIX_STATE_DIR=${config.home.sessionVariables.NIX_STATE_DIR}
    export NIX_PROFILE=${config.home.sessionVariables.NIX_PROFILE}
    export PATH=$NIX_PROFILE/bin:$PATH:${pkgs.nix}/bin
    # support for x86_64/aarch64
    # include .bashrc if it exists
    [[ -f ~/.bashrc.$(uname -m) ]] && . ~/.bashrc.$(uname -m)
  '';
  programs.bash.profileExtra = ''
    # support for x86_64/aarch64
    # include .profile if it exists
    [[ -f ~/.profile.$(uname -m) ]] && . ~/.profile.$(uname -m)
  '';
  home.activation.setNixVariables = lib.hm.dag.entryBefore [ "writeBoundary" "checkLinkTargets" "checkFilesChanges" ]
    ''
      set -x
      export NIX_STATE_DIR=${config.home.sessionVariables.NIX_STATE_DIR}
      export NIX_PROFILE=${config.home.sessionVariables.NIX_PROFILE}
      export PATH=${pkgs.nix}/bin:$PATH
      rm -rf ${config.home.profileDirectory}
      ln -sf ${config.home.sessionVariables.NIX_PROFILE} ${config.home.profileDirectory}
      export HOME_MANAGER_BACKUP_EXT=bak
      nix-env --set-flag priority 80 nix || true
      set +x
    '';
  home.sessionPath = [
    "${pkgs.nix}/bin"
  ];

  home.packages = with pkgs; [
    xpra
    bashInteractive

    datalad
    git-annex
  ];

}
