{ lib, config, ... }:
{
  flake.aspects.dguibert-annex.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-annex
  ];
  flake.aspects.dguibert-annex.homeManager =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        mr
        #mercurial
        #previousPkgs_pu.git-annex
        yt-dlp
        git-nomad
        git-annex
        git-annex-remote-rclone
        (pkgs.writeScriptBin "git-annex-diff-wrapper" ''
          #!${pkgs.runtimeShell}
          LANG=C ${pkgs.diffutils}/bin/diff -u "$1" "$2"
          exit 0
        '')
        bup
        par2cmdline
        fpart # ~/Makefile ~/bin/prepare-bd.sh
        rclone
        datalad

        imagemagick
        exiftool
        udftools
        hub # command-line wrapper for git that makes you better at GitHub
      ];
    };
}
