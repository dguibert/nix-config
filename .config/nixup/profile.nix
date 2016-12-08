# NixUP configuration root file

{config, lib, pkgs, ...}:

with lib;

{
  config = {

    imperativeNix.enable = true;

    user.packages = with pkgs; [
      vim
      gitAndTools.git-annex
      mr
      vcsh
      gitFull
      (conky.override { x11Support = false; })
      fossil
      gitAndTools.gitRemoteGcrypt
      dwm dmenu xlockmore xautolock xorg.xset xorg.xinput xorg.xsetroot xorg.setxkbmap xorg.xmodmap rxvt_unicode st
    ];

    user.pathsToLink = [
      "/bin"
      "/etc/xdg"
      "/info"
      "/man"
      "/sbin"
      "/share/emacs"
      "/share/vim-plugins"
      "/share/org"
      "/share/info"
      "/share/terminfo"
      "/share/man"
      "/share/mr"
      "/share/icons"
    ];

    systemd.services.fossil-mpisortv = {
      wantedBy = [ "default.target" ];
      description = "Fossil Mpi_SortV";
      path = [ pkgs.fossil ];
      script = "fossil server ~/code/mpi_sortv/mpi_sortv.fossil --port 8055";
    };
  };

}