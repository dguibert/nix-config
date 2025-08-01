{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.x11-conf.enable = lib.mkEnableOption "x11-conf";
  config = lib.mkIf config.x11-conf.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.xkb.layout = "fr";
    services.xserver.xkb.options = "eurosign:e";

    #services.xserver.videoDrivers = [ "intel" "displaylink" ]; # error: Package ‘evdi-1.4.1+git2017-06-12’ in /home/dguibert/code/nixpkgs/pkgs/os-specific/linux/evdi/default.nix:26 is marked as broken, refusing to evaluate.
    hardware.graphics.enable32Bit = true;

    #  services.xserver.desktopManager.default = "gnome3";
    #  services.xserver.desktopManager.gnome3.enable = true;
    #  networking.wireless.enable = mkForce false; # - You can not use networking.networkmanager with services.networking.wireless
    # TODO check incompatibilities with home-manager xsession
    services.xserver.displayManager.autoLogin.enable = true;
    services.xserver.displayManager.autoLogin.user = "dguibert";
    services.xserver.desktopManager.xterm.enable = true;

    fonts.fontDir.enable = true;
    fonts.enableGhostscriptFonts = true;
    fonts.fontconfig.enable = true;
    fonts.fontconfig.antialias = true;
    fonts.fontconfig.hinting.enable = true;
    fonts.fonts = with pkgs; [
      terminus_font
      powerline-fonts
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      # corefonts
      #noto-fonts
      #noto-fonts-cjk
      #noto-fonts-emoji
      #liberation_ttf
      #fira-code
      #fira-code-symbols
      #mplus-outline-fonts
      #dina-font
      #proggyfonts
    ];

    # Enable the KDE Desktop Environment.
    # services.xserver.displayManager.kdm.enable = true;
    # services.xserver.desktopManager.kde4.enable = true;

    security.wrappers.xlock = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.xlockmore}/bin/xlock";
    };
  };
}
