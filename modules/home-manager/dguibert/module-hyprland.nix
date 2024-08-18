{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.hyprland;
in
with lib; {
  options.hyprland.nvidia.enable = lib.mkEnableOption "Hyprland with NVidia GPU";

  config = lib.mkIf config.withGui.enable {
    programs.bash.bashrcExtra = ''
      if [[ -z $WAYLAND_DISPLAY ]] && [[ "$XDG_VTNR" -eq 1 ]] && command -v Hyprland >/dev/null ; then
      dbus-run-session Hyprland
      fi
    '';

    home.packages = with pkgs; [
      wl-clipboard
      alacritty # Alacritty is the default terminal in the config
      dmenu-wayland # Dmenu is the default in the config but i recommend wofi since its wayland native
      swaylock # lockscreen
      swayidle
      wlr-randr
      xwayland # for legacy apps
      mako # notification daemon
      brightnessctl

      adwaita-icon-theme # Icons for gnome packages that sometimes use them but don't depend on them

      waypipe
      grim
      slurp
      wayvnc

      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    ];

    programs.foot.enable = true;
    programs.foot.server.enable = true;
    programs.foot.settings = {
      main = {
        term = "xterm";

        dpi-aware = "yes";
      };
      scrollback = {
        lines = "100000";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };

    systemd.user.services.mako = {
      Unit = {
        Description = "Mako notification daemon";
        PartOf = [ "hyprland-session.target" ];
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${pkgs.mako}/bin/mako";
        RestartSec = 5;
        Restart = "always";
      };
    };

    services.swayidle.enable = true;
    services.swayidle.systemdTarget = "hyprland-session.target";
    services.swayidle.timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
      { timeout = 360; command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off"; }
    ];
    services.swayidle.events = [
      { event = "after-resume"; command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on"; }
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f -c 000000"; }
    ];

    xdg.configFile."waybar/style.css".source = ./waybar-style.css;
    xdg.configFile."waybar/config".text =
      let
        default_conf = mon: {
          layer = "top";
          output = mon;
          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-right = [ "pulseaudio" "battery" "backlight" "network" "clock" "tray" ];
          backlight = { };
          battery = {
            format = "{capacity}% {icon}";
            format-icons = [ "" "" "" "" "" ];
          };
          clock.format-alt = "{:%a, %d. %b  %H:%M}";
          tray = {
            icon-size = 21;
            spacing = 10;
          };
          pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-muted = "";
            format-icons = {
              headphones = "";
              phone = "";
              portable = "";
              default = [ "" "" ];
            };
            scroll-step = 1;
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
          "hyprland/workspaces" = {
            active-only = false;
            all-outputs = false;
            #format = "<sub>{icon}</sub>\n{windows}";
            #format = "{name}: {icon}";
            #format-icons = {
            #  #"1" =  "";
            #  #"2" =  "";
            #  #"3" =  "";
            #  #"4" =  "";
            #  #"5" =  "";
            #  #"active" =  "";
            #  #"default" =  "";
            #};
            persitent-workspaces."*" = 9;
            window-rewrite = {
              "title<.*youtube.*>" = ""; # Windows whose titles contain "youtube"
              "class<firefox>" = ""; # Windows whose classes are "firefox"
              "class<firefox> title<.*github.*>" = ""; # Windows whose class is "firefox" and title contains "github". Note that "class" always comes first.
              "foot" = ""; # Windows that contain "foot" in either class or title. For optimization reasons; it will only match against a title if at least one other window explicitly matches against a title.
              "code" = "󰨞";
            };
          };
          "hyprland/window" = {
            max-length = 200;
            separate-outputs = true;
          };
          network = {
            #interface = "bond0";
            format = "{ifname}";
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{bandwidthDownBytes}  {bandwidthUpBytes}";
            #format-disconnected = ""; # An empty format will hide the module.
            format-disconnected = ""; # An empty format will hide the module.
            tooltip-format = "{ipaddr}/{cidr} {ifname} via {gwaddr}";
            tooltip-format-wifi = "{essid} ({signalStrength}%) ";
            tooltip-format-ethernet = "{ifname} ";
            tooltip-format-disconnected = "Disconnected";
            max-length = 50;
          };
        };
      in
      builtins.toJSON
        [
          (default_conf "HDMI-A-1")
          (default_conf "DVI-D-1")
          (default_conf "eDP-1")
        ];

    systemd.user.services.waybar = {
      Unit = {
        Description = "Modular status panel for Wayland";
        PartOf = [ "tray.target" ];
      };
      Install = {
        WantedBy = [ "tray.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.waybar}/bin/waybar";
        RestartSec = 5;
        Restart = "always";
      };
    };

    systemd.user.targets.hyprland-session.Unit = {
      Wants = [ "tray.target" ];
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      plugins = [
        inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
      ];
      settings = {
        plugin.split-monitor-workspaces = {
          count = 10; # 9 are used but 1-9 are on 1st monitor, 11-19 are on snd
          keep_focused = 0;
          enable_notifications = 0;
          enable_persistent_workspaces = 0;
        };
        env = lib.mkIf cfg.nvidia.enable [
          "LIBVA_DRIVER_NAME,nvidia"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia" # to be removed if problems with discord or screen sharing with zoom
          "WLR_NO_HARDWARE_CURSORS,1"
        ];
        bind = [
          ", Print, exec, grimblast copy area"
          #",Print,exec,grim -g "$(slurp)" -t png - | wl-copy -t image/png"
        ];
      };
      extraConfig = builtins.readFile ./hyprland.conf;
      systemd = {
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };
    };
  };

}
