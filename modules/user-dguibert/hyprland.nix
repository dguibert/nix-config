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
    hyprsplit.url = "github:shezdy/hyprsplit";
    hyprsplit.inputs.nixpkgs.follows = "nixpkgs";
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
              status:
              "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = \"${status}\" })' ";
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
                command = display "disable";
                resumeCommand = (display "enable") + "; " + (notif_mode "default");
              }
              #{
              #  timeout = 30;
              #  command = "${pkgs.systemd}/bin/systemctl suspend";
              #}
            ];
            events.before-sleep = lock + "; " + (display "disable");
            events.after-resume = display "enable";
            events.lock = lock + "; " + (display "disable") + "; " + (notif_mode "away");
            events.unlock = (display "enable") + "; " + (notif_mode "default");
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

        xdg.configFile."hypr/hyprsplit" = lib.mkIf cfg.hyprsplit.enable {
          source = "${
            inputs.hyprsplit.packages.${toString pkgs.stdenv.hostPlatform.system}.hyprsplitlua
          }/share/hyprsplit";
          recursive = true;
        };

        wayland.windowManager.hyprland = {
          configType = "lua";
          enable = true;
          settings = {
            mod._var = "SUPER";
            env = [
              {
                _args = [
                  "XCURSOR_SIZE"
                  "24"
                ];
              }
              {
                _args = [
                  "GDK_BACKEND"
                  "wayland,x11"
                ];
              }
              {
                _args = [
                  "SDL_VIDEODRIVER"
                  "wayland"
                ];
              }
              {
                _args = [
                  "CLUTTER_BACKEND"
                  "wayland"
                ];
              }
              {
                _args = [
                  "XDG_CURRENT_DESKTOP"
                  "Hyprland"
                ];
              }
              {
                _args = [
                  "XDG_SESSION_TYPE"
                  "wayland"
                ];
              }
              {
                _args = [
                  "XDG_SESSION_DESKTOP"
                  "Hyprland"
                ];
              }
              {
                _args = [
                  "QT_QPA_PLATFORM"
                  "wayland"
                ];
              }
              {
                _args = [
                  "QT_AUTO_SCREEN_SCALE_FACTOR"
                  "1"
                ];
              }
              {
                _args = [
                  "QT_WAYLAND_DISABLE_WINDOWDECORATION"
                  "1"
                ];
              }
              {
                _args = [
                  "QT_QPA_PLATFORMTHEME"
                  "qt6ct"
                ];
              }
            ]
            ++ lib.optionals cfg.nvidia.enable [
              {
                _args = [
                  "LIBVA_DRIVER_NAME"
                  "nvidia"
                ];
              }
              {
                _args = [
                  "GBM_BACKEND"
                  "nvidia-drm"
                ];
              }
              {
                _args = [
                  "WLR_NO_HARDWARE_CURSORS"
                  "1"
                ];
              }
              #"__GLX_VENDOR_LIBRARY_NAME" " " "nvidia" # to be removed if problems with discord or screen sharing with zoom;
              #{ _args = [ "__GLX_VENDOR_LIBRARY_NAME" "mesa" ]; } # for orca-slicer
              #{ _args = [ "__EGL_VENDOR_LIBRARY_FILENAMES" "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json" ]; }
              #{ _args = [ "MESA_LOADER_DRIVER_OVERRIDE" "zink" ]; }
              #{ _args = [ "GALLIUM_DRIVER" "zink" ]; }
              #{ _args = [ "WEBKIT_DISABLE_DMABUF_RENDERER" "1" ]; }
            ];
            monitor = [
              {
                output = "";
                mode = "preferred";
                position = "auto";
                scale = "auto";
              }
              {
                output = "desc:Lenovo Group Limited LEN T24d-10 V5GG2005";
                mode = "preferred";
                position = "1920x0";
                scale = "auto";
              }
              {
                output = "desc:Lenovo Group Limited LEN T24d-10 V5FTW686";
                mode = "preferred";
                position = "0x0";
                scale = "auto";
              }
              {
                output = "desc:Lenovo Group Limited 0x40BA";
                mode = "preferred";
                position = "auto";
                scale = "1";
              }
              {
                output = "VGA-1";
                disabled = true;
              }
              {
                output = "Unknown-1";
                disabled = true;
              }
              #monitor=Unknown-1,disable
              #monitor=VGA-1,disable
              #monitor=desc:Lenovo Group Limited 0x40BA,preferred,auto,1

            ];
            config = {
              input = {
                kb_layout = "fr";
                follow_mouse = 1;
                touchpad.natural_scroll = false;
                sensitivity = 0;
              };
              general = {
                gaps_in = 0;
                gaps_out = 0;
                col.active_border = "rgba(005577ff)";
                col.inactive_border = "rgba(444444ff)";

                layout = "master";

              };
              decoration.rounding = 2;
              misc = {
                mouse_move_enables_dpms = true;
                key_press_enables_dpms = true;
              };
              master = {
                new_status = "master";
                new_on_top = true;
              };
            };
            bind = [
              {
                _args = [
                  ("SUPER + SHIFT + RETURN")
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"foot\")")
                ];
              }
              {
                _args = [
                  ("SUPER + P")
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dmenu-wl_run -i\")")
                ];
              }
              {
                _args = [
                  ("SUPER + SHIFT + L")
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pkill -USR1 swayidle\")")
                ];
              }
              {
                _args = [
                  ("SUPER + SHIFT + C")
                  (lib.generators.mkLuaInline "hl.dsp.window.close()")
                ];
              }
              {
                _args = [
                  "Print"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"grimblast copy area\")")
                  #",Print,exec,grim -g "$(slurp)" -t png - | wl-copy -t image/png"
                ];
              }
              {
                _args = [
                  ("SUPER + h")
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"mfact -0.01\")")
                  "{ repeating = true })"
                ];
              }
              {
                _args = [
                  ("SUPER + l")
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"mfact +0.01\")")
                  "{ repeating = true })"
                ];
              }
              {
                _args = [
                  "SUPER + k"
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"cyclenext\")")
                ];
              }
              {
                _args = [
                  "SUPER + j"
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"cycleprev\")")
                ];
              }
              {
                _args = [
                  "SUPER + d"
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"removemaster\")")
                ];
              }
              {
                _args = [
                  "SUPER + i"
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"addmaster\")")
                ];
              }
              {
                _args = [
                  "SUPER + return"
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwithmaster\")")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + k"
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"swapnext\")")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + j"
                  (lib.generators.mkLuaInline "hl.dsp.layout(\"swapprev\")")
                ];
              }
              {
                _args = [
                  ("SUPER + SHIFT + Space")
                  (lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
                  "{ description = \"Window: Float/Tile\" })"
                ];
              }
              {
                _args = [
                  ("SUPER + M")
                  (lib.generators.mkLuaInline "hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\" })")
                  "{ description = \"Window: Maximize\" })"
                ];
              }
              {
                _args = [
                  ("SUPER + F")
                  (lib.generators.mkLuaInline "hl.dsp.window.fullscreen({ mode = \"fullscreen\", action = \"toggle\" })")
                  "{ description = \"Window: Fullscreen\" })"
                ];
              }
              {
                _args = [
                  "SUPER + mouse:272"
                  (lib.generators.mkLuaInline "hl.dsp.window.drag()")
                  "{ mouse = true, description = \"Window: Move\" }"
                ];
              }
              {
                _args = [
                  "SUPER + mouse:273"
                  (lib.generators.mkLuaInline "hl.dsp.window.resize()")
                  "{ mouse = true, description = \"Window: Resize\" }"
                ];
              }

              {
                _args = [
                  "XF86AudioRaiseVolume"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1.2 @DEFAUT_AUDIO_SINK@ 6%+\")")
                  "{ locked = true, repeating = true }"
                ];
              }
              {
                _args = [
                  "XF86AudioLowerVolume"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1.2 @DEFAUT_AUDIO_SINK@ 6%-\")")
                  "{ locked = true, repeating = true }"
                ];
              }
              {
                _args = [
                  "XF86AudioMute"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAUT_AUDIO_SINK@ toggle\")")
                  "{ locked = true }"
                ];
              }
              {
                _args = [
                  "XF86AudioMicMute"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAUT_AUDIO_SOURCE@ toggle\")")
                  "{ locked = true }"
                ];
              }

              {
                _args = [
                  "XF86MonBrightnessUp"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl s 2%+\")")
                  "{ locked = true, repeating = true }"
                ];
              }
              {
                _args = [
                  "XF86MonBrightnessDown"
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl s 2%-\")")
                  "{ locked = true, repeating = true }"
                ];
              }
            ];
          };
          extraConfig = ''
            local hs = require("hyprsplit")
            hs.config({ num_workspaces = 10 })

            for i = 1, 10 do
                local azerty_keys = {"ampersand", "eacute", "quotedbl", "apostrophe", "parenleft", "minus", "egrave", "underscore", "ccedilla", "agrave" }
                hl.bind("SUPER + " .. azerty_keys[i], hs.dsp.focus({ workspace = i }))
                hl.bind("SUPER + SHIFT + " .. azerty_keys[i], hs.dsp.window.move({ workspace = i, follow = true }))
            end

            hl.bind("SUPER + " .. "g", hs.dsp.grab_rogue_windows())
            -- hl.bind("SUPER + " .. "d", hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))

            --#/# bind = SUPER + ←/↑/→/↓,, -- Focus in direction
            for i = 1, 4 do
                local arrowkey = { "Left", "Right", "Up", "Down" }
                local focusdir = { "l", "r", "u", "d" }
                hl.bind("SUPER + " .. arrowkey[i], hl.dsp.focus({ direction = focusdir[i] }),
                    { description = "Window: Focus " .. arrowkey[i] })
            end
            for i = 1, 2 do
                local arrowkey = { "tab", "backspace" }
                local focusdir = { "previous", "previous_per_monitor" }
                hl.bind("SUPER + " .. arrowkey[i], hl.dsp.focus({ workspace = focusdir[i] }))
            end
            --#/# bind = SUPER + SHIFT, ←/↑/→/↓,, -- Move in direction
            for i = 1, 4 do
                local arrowkey = { "Left", "Right", "Up", "Down" }
                local focusdir = { "l", "r", "u", "d" }
                hl.bind("SUPER + SHIFT + " .. arrowkey[i], hl.dsp.window.move({ direction = focusdir[i] }),
                    { description = "Window: Move " .. arrowkey[i] })
            end
            for i = 1, 2 do
                local arrowkey = { "tab", "backspace" }
                local focusdir = { "previous", "previous_per_monitor" }
                hl.bind("SUPER + SHIFT + " .. arrowkey[i], hl.dsp.window.move({ workspace = focusdir[i] }))
            end

          '';
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
