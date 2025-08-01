{
  config,
  pkgs,
  lib,
  ...
}:

let

  # https://git.sr.ht/~raphi/dwl/tree/master/item/dwl-session
  dwl-session = pkgs.writeShellScriptBin "dwl-session" ''
    #!/bin/sh
    set -e
    maybe() {
      command -v "$1" > /dev/null && "$@"
    }

    if [ "$1" = 'startup' ]; then
      # this is hell
      dbus-update-activation-environment --systemd \
        QT_QPA_PLATFORM WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

      #maybe ~/.local/lib/pulseaudio-watch someblocks &
      #PATH=~/code/someblocks:$PATH someblocks &
      #swaybg -i ~/Pictures/wallpaper.png -o '*' -m fit &
      #somebar
      cat > ~/.cache/dwltags

      # kill any remaining background tasks
      for pid in $(pgrep -g $$); do
        test "$$" != "$pid" && kill "$pid"
      done
    else
      if [ -e /dev/nvidiactl ]; then
        export WLR_NO_HARDWARE_CURSORS=1
      fi
      export QT_QPA_PLATFORM=wayland-egl
      export XDG_CURRENT_DESKTOP=wlroots

      # Start systemd user services for graphical sessions
      /run/current-system/systemd/bin/systemctl --user start hm-graphical-session.target

      #exec dwl -s "setsid -w $0 startup <&-" |& tee ~/dwl-session.log
      exec dwl -s "setsid -w $0 startup" |& tee ~/dwl-session.log
    fi
  '';

  # https://git.sr.ht/~raphi/dotfiles/tree/nixos/item/.local/lib/pulseaudio-watch

  wlr-toggle = pkgs.writeShellScriptBin "wlr-toggle" ''
    #!/bin/sh

    ''${VERBOSE:-true} && set -x
    arg=''${1:-}
    export PATH=''${PATH+$PATH:}${pkgs.wlr-randr}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin
    command -v wlr-randr

    outputs=$(wlr-randr | awk '$1 ~ /^[A-Za-z-]+-[1-9]/ { print $1; } { next; } ')
    for output in $outputs; do
      options+=" --output $output --''${arg:-on}"
    done
    wlr-randr $options
  '';

  # https://codeberg.org/fauxmight/waybar-dwl/raw/branch/main/waybar-dwl.sh
  waybarDwlScript = pkgs.replaceVarsWith {
    src = ./waybar-dwl.sh;
    replacements = {
      inotifyTools = pkgs.inotify-tools;
      bash = pkgs.bash;
    };
    isExecutable = true;
  };

in
with lib;
{
  options.withDwl.enable = (lib.mkEnableOption "Enable Dwl config") // {
    default = false;
  };

  config = lib.mkIf (config.withDwl.enable) {
    programs.bash.bashrcExtra = ''
      if [[ -z $WAYLAND_DISPLAY ]] && [[ $(tty) = /dev/tty1 ]] && command -v dwl-session >/dev/null ; then
      exec dwl-session
      fi
    '';

    home.packages = with pkgs; [
      dwl-session
      dwl
      somebar
      wl-clipboard
      alacritty # Alacritty is the default terminal in the config
      dmenu-wayland # Dmenu is the default in the config but i recommend wofi since its wayland native
      swaylock # lockscreen
      swayidle
      wlr-randr
      mako # notification daemon
      kanshi # autorandr
      brightnessctl

      adwaita-icon-theme # Icons for gnome packages that sometimes use them but don't depend on them

      waypipe
      grim
      slurp
      wayvnc
    ];

    programs.foot.enable = true;
    programs.foot.server.enable = true;
    programs.foot.settings = {
      main = {
        term = "xterm";

        font = "Fira Code:size=11";
        dpi-aware = "no";
      };
      scrollback = {
        lines = "100000";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };

    #systemd.user.sockets.dbus = {
    #  Unit = {
    #    Description = "D-Bus User Message Bus Socket";
    #  };
    #  Socket = {
    #    ListenStream = "%t/bus";
    #    ExecStartPost = "${pkgs.systemd}/bin/systemctl --user set-environment DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";
    #  };
    #  Install = {
    #    WantedBy = [ "sockets.target" ];
    #    Also = [ "dbus.service" ];
    #  };
    #};

    #systemd.user.services.dbus = {
    #  Unit = {
    #    Description = "D-Bus User Message Bus";
    #    Requires = [ "dbus.socket" ];
    #  };
    #  Service = {
    #    ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation";
    #    ExecReload = "${pkgs.dbus}/bin/dbus-send --print-reply --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig";
    #  };
    #  Install = {
    #    Also = [ "dbus.socket" ];
    #  };
    #};

    #systemd.user.services.dwl = {
    #  Unit = {
    #    Description = "DWL - Wayland window manager";
    #    BindsTo = [ "graphical-session.target" ];
    #    Wants = [ "graphical-session-pre.target" ];
    #    After = [ "graphical-session-pre.target" ];
    #  };
    #  Service = {
    #    Type = "simple";
    #    ExecStart = "${pkgs.dwl}/bin/dwl -s ${pkgs.somebar}/bin/somebar";
    #    Restart = "on-failure";
    #    RestartSec = 1;
    #    TimeoutStopSec = 10;
    #  };
    #};

    systemd.user.services.mako = {
      Unit = {
        Description = "Mako notification daemon";
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${pkgs.mako}/bin/mako";
        RestartSec = 5;
        Restart = "always";
      };
    };

    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle display configuration";
        PartOf = [ "graphical-session.target" ];
        ConditionHost = "t580";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swayidle}/bin/swayidle -d -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 000000' timeout 360 '${wlr-toggle}/bin/wlr-toggle off' resume '${wlr-toggle}/bin/wlr-toggle on' before-sleep '${pkgs.swaylock}/bin/swaylock -f -c 000000'";
        RestartSec = 5;
        Restart = "always";
      };
    };

    systemd.user.services.kanshi = {
      Unit = {
        Description = "Kanshi dynamic display configuration";
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kanshi}/bin/kanshi";
        RestartSec = 5;
        Restart = "always";
      };
    };

    xdg.configFile."kanshi/config".text = ''
      profile {
        output HDMI-A-1 enable mode 1920x1200 position 0,0
        output DVI-D-1 enable mode 1920x1200 position 1920,0
      }
      profile {
        output eDP-1 enable mode 1920x1080 position 0,0
      }
      profile {
        output "Lenovo Group Limited LEN T24d-10 V5GG2005" enable mode 1920x1080 position 0,0
        output eDP-1 enable mode 1920x1080 position 1920,0
      }
      profile {
        output "Philips Consumer Electronics Company PHL 241B7QG 0x000004CC" enable mode 1920x1080 position 0,0
        output eDP-1 enable mode 1920x1080 position 1920,0
      }
    '';

    #systemd.user.services.someblocks = {
    #  Unit = {
    #    Description = "someblocks";
    #    PartOf = [ "graphical-session.target" ];
    #  };
    #  Install = {
    #    WantedBy = [ "graphical-session.target" ];
    #  };
    #  Service = {
    #    Type = "simple";
    #    ExecStart = "${pkgs.someblocks}/bin/someblocks";
    #    RestartSec = 5;
    #    Restart = "always";
    #  };
    #};
    xdg.configFile."waybar/config".text =
      let
        default_conf =
          mon:
          {
            layer = "top";
            output = mon;
            modules-left = [
              "custom/dwl_tag#0"
              "custom/dwl_tag#1"
              "custom/dwl_tag#2"
              "custom/dwl_tag#3"
              "custom/dwl_tag#4"
              "custom/dwl_tag#5"
              "custom/dwl_tag#6"
              "custom/dwl_tag#7"
              "custom/dwl_tag#8"
              "custom/dwl_layout"
              "custom/dwl_title"
            ];
            modules-right = [
              "pulseaudio"
              "battery"
              "backlight"
              "network"
              "clock"
              "tray"
            ];
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
            network = {
              interface = "bond0";
              format = "{ifname}";
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{bandwidthDownBytes} {bandwidthUpBytes} ";
              format-disconnected = ""; # An empty format will hide the module.
              tooltip-format = "{ipaddr}/{cidr} {ifname} via {gwaddr} ";
              tooltip-format-wifi = "{essid} ({signalStrength}%) ";
              tooltip-format-ethernet = "{ifname} ";
              tooltip-format-disconnected = "Disconnected";
              max-length = 50;
            };
            "custom/dwl_layout" = {
              exec = "${waybarDwlScript} '${mon}' layout";
              format = "{}";
              escape = true;
              return-type = "json";
            };
            "custom/dwl_title" = {
              exec = "${waybarDwlScript} '${mon}' title";
              format = "{}";
              escape = true;
              return-type = "json";
            };
          }
          // (builtins.foldl' (x: y: x // y) { } (
            builtins.map
              (tag: {
                "custom/dwl_tag#${tag}" = {
                  exec = "${waybarDwlScript} '${mon}' ${tag}";
                  format = "{}";
                  return-type = "json";
                };
              })
              [
                "0"
                "1"
                "2"
                "3"
                "4"
                "5"
                "6"
                "7"
                "8"
              ]
          ));
      in
      builtins.toJSON [
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

    systemd.user.targets = {
      # A basic graphical session target for Home Manager.
      hm-graphical-session = {
        Unit = {
          Description = "Home Manager X session";
          Requires = [ "graphical-session-pre.target" ];
          BindsTo = [
            "graphical-session.target"
            "tray.target"
          ];
        };
      };

      tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
        };
      };
    };
  };

}
