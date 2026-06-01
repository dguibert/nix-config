{
  inputs,
  lib,
  config,
  ...
}:
let
  config_ = config;
in
{
  flake-file.inputs = {
    hyprland-contrib.url = "github:hyprwm/contrib";
  };

  flake.aspects.dguibert-hyprland.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-hyprland
  ];
  flake.aspects.dguibert-hyprland.homeManager =
    { pkgs, config, ... }:
    let
      cfg = config.hyprland;
    in
    with lib;
    {
      options.hyprland.enable = (lib.mkEnableOption "Enable hyprland config") // {
        default = false;
      };
      options.hyprland.hyprsplit.enable = (lib.mkEnableOption "Hyprland with split plugin") // {
        default = true;
      };
      options.hyprland.nvidia.enable = (lib.mkEnableOption "Hyprland with NVidia GPU") // {
        default = false;
      };

      config = lib.mkIf cfg.enable {
        programs.bash.bashrcExtra = ''
          if [[ -z $WAYLAND_DISPLAY ]] && [[ "$XDG_VTNR" -eq 1 ]] && command -v start-hyprland >/dev/null ; then
            dbus-run-session start-hyprland
          fi
        '';

        home.packages = with pkgs; [
          wl-clipboard
          alacritty # Alacritty is the default terminal in the config
          dmenu-wayland # Dmenu is the default in the config but i recommend wofi since its wayland native
          wlr-randr
          brightnessctl

          adwaita-icon-theme # Icons for gnome packages that sometimes use them but don't depend on them

          waypipe
          grim
          slurp
          wayvnc

          inputs.hyprland-contrib.packages.${toString stdenv.hostPlatform.system}.grimblast
        ];

        custom-foot.enable = true;
        custom-mako.enable = true;
        custom-mako.systemdTarget = "hyprland-session.target";

        services.swayidle =
          let
            # Lock command
            lock = "${pkgs.swaylock}/bin/swaylock --daemonize -c 000000";
            # TODO: modify "display" function based on your window manager
            # Sway
            # display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
            # Hyprland
            display =
              status: "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms ${status}";
            # Niri
            # display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
            notif_mode = status: "${config.services.mako.package}/bin/makoctl mode -s ${status}";
          in
          {
            enable = true;
            systemdTargets = [ "hyprland-session.target" ];
            timeouts = [
              {
                timeout = 280; # in seconds
                command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
              }
              {
                timeout = 300;
                command = lock;
              }
              {
                timeout = 320;
                command = display "off";
                resumeCommand = (display "on") + "; " + (notif_mode "default");
              }
              #{
              #  timeout = 30;
              #  command = "${pkgs.systemd}/bin/systemctl suspend";
              #}
            ];
            events.before-sleep = lock + "; " + (display "off");
            events.after-resume = display "on";
            events.lock = lock + "; " + (display "off") + "; " + (notif_mode "away");
            events.unlock = (display "on") + "; " + (notif_mode "default");
          };

        xdg.configFile."waybar/style.css".source = ./waybar-style.css;
        xdg.configFile."waybar/config".text =
          let
            default_conf = mon: interface: {
              layer = "top";
              output = mon;
              modules-left = [
                "hyprland/workspaces"
                "hyprland/window"
              ];
              modules-right = [
                "pulseaudio"
                "battery"
                "backlight"
                "network"
                "clock"
                "tray"
                "custom/mako"
              ];
              "custom/mako" = {
                exec = pkgs.writeShellScript "mako-mode.sh" ''
                  mode=$(${config.services.mako.package}/bin/makoctl mode)
                  case $mode in
                    dnd)
                    TEXT="dnd"
                    CLASS=activated
                    ;;
                    *)
                    TEXT="$mode"
                    CLASS=deactivated
                    ;;
                  esac
                  printf '{"text": "%s", "class": "%s"}\n' "$TEXT" "$CLASS"
                '';
                return-type = "json";
                interval = 120;
                on-click = "${config.services.mako.package}/bin/mako -t dnd";
                # $text\n$tooltip\n$class
                format = "{} {icon}";
                format-icons = {
                  activated = " ";
                  deactivated = " ";
                };
                tooltip = true;
                tooltip-format = "Toggle DND on/off";
              };
              backlight = { };
              battery = {
                format = "{capacity}% {icon}";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                  ""
                ];
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
                  default = [
                    ""
                    ""
                  ];
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
                interface = interface;
                format = "{ifname}";
                format-wifi = "{bandwidthDownBytes}  {bandwidthUpBytes}  {essid} ({signalStrength}%) ";
                format-ethernet = "{bandwidthDownBytes}  {bandwidthUpBytes}";
                format-disconnected = ""; # An empty format will hide the module.
                #format-disconnected = ""; # An empty format will hide the module.
                tooltip-format = "{ipaddr}/{cidr} {ifname} via {gwaddr}";
                tooltip-format-wifi = "{essid} ({signalStrength}%) ";
                tooltip-format-ethernet = "{ifname} ";
                tooltip-format-disconnected = "Disconnected";
                max-length = 50;
              };
            };
          in
          builtins.toJSON [
            (default_conf "HDMI-A-1" "bond0")
            (default_conf "DVI-D-1" "bond0")
            (default_conf "eDP-1" "wlan0")
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
          plugins = lib.optionals cfg.hyprsplit.enable [
            pkgs.hyprlandPlugins.hyprsplit
          ];
          settings = {
            plugin.hyprsplit.num_workspaces = 10;

            env = lib.mkIf cfg.nvidia.enable [
              "LIBVA_DRIVER_NAME,nvidia"
              "GBM_BACKEND,nvidia-drm"
              "WLR_NO_HARDWARE_CURSORS,1"
              #"__GLX_VENDOR_LIBRARY_NAME,nvidia" # to be removed if problems with discord or screen sharing with zoom
              "__GLX_VENDOR_LIBRARY_NAME,mesa" # for orca-slicer
              "__EGL_VENDOR_LIBRARY_FILENAMES,${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json"
              "MESA_LOADER_DRIVER_OVERRIDE,zink"
              "GALLIUM_DRIVER,zink"
              "WEBKIT_DISABLE_DMABUF_RENDERER,1"
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

    };
}
