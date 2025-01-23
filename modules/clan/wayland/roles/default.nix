{ config, lib, pkgs, ... }:
let
  cfg = config.clan.wayland;
in
{
  options.clan.wayland.enable32Bit = lib.mkOption {
    description = "Wether to enable 32bit support";
    default = true;
    type = lib.types.bool;
  };
  config = {
    nix.settings = {
      # add binary caches
      trusted-public-keys = [
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      substituters = [
        "https://nixpkgs-wayland.cachix.org"
      ];
    };
    services.seatd.enable = true;
    security.polkit.enable = true;

    security.pam.services.swaylock = { };

    hardware.graphics.enable = lib.mkDefault true;
    hardware.graphics.enable32Bit = cfg.enable32Bit;

    fonts.enableDefaultPackages = lib.mkDefault true;
    fonts.fontDir.enable = true;
    fonts.enableGhostscriptFonts = true;
    fonts.fontconfig.enable = true;
    fonts.fontconfig.antialias = true;
    fonts.fontconfig.hinting.enable = true;
    fonts.packages = with pkgs ; [
      terminus_font
      powerline-fonts
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      emacs-all-the-icons-fonts
      /*corefonts*/
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

    programs.dconf.enable = lib.mkDefault true;

    xdg = {
      portal = {
        wlr.enable = true;
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
        config.common.default = "*";
      };
    };

    # Enable sound.
    # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
    #sound.enable = false;

    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = cfg.enable32Bit;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
      ## low-latency pulse backend https://nixos.wiki/wiki/PipeWire
      #config.pipewire-pulse = {
      #  "context.properties" = {
      #    "log.level" = 2;
      #  };
      #  "context.modules" = [
      #    {
      #      name = "libpipewire-module-rtkit";
      #      args = {
      #        "nice.level" = -15;
      #        "rt.prio" = 88;
      #        "rt.time.soft" = 200000;
      #        "rt.time.hard" = 200000;
      #      };
      #      flags = [ "ifexists" "nofail" ];
      #    }
      #    { name = "libpipewire-module-protocol-native"; }
      #    { name = "libpipewire-module-client-node"; }
      #    { name = "libpipewire-module-adapter"; }
      #    { name = "libpipewire-module-metadata"; }
      #    {
      #      name = "libpipewire-module-protocol-pulse";
      #      args = {
      #        "pulse.min.req" = "32/48000";
      #        "pulse.default.req" = "32/48000";
      #        "pulse.max.req" = "32/48000";
      #        "pulse.min.quantum" = "32/48000";
      #        "pulse.max.quantum" = "32/48000";
      #        "server.address" = [ "unix:native" ];
      #      };
      #    }
      #  ];
      #  "stream.properties" = {
      #    "node.latency" = "32/48000";
      #    "resample.quality" = 1;
      #  };
      #};
    };
  };
}
