{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom-mako;
in
with lib;
{
  options.custom-mako.enable = (lib.mkEnableOption "Enable custom mako config") // {
    default = false;
  };
  options.custom-mako.systemdTarget = lib.mkOption {
    description = "define the session target";
    example = "hyprland-session.target";
  };

  config = lib.mkIf cfg.enable {
    # notification daemon
    services.mako.enable = true;
    services.mako.settings = {
      max-visible = 3;
      layer = "overlay";
      # == Mode: Away ==
      "mode=away" = {
        default-timeout = 0;
        ignore-timeout = 1;
      };

      # == Mode: Do Not Disturb ==
      "mode=dnd".invisible = 1;
    };

    systemd.user.services.mako = {
      Unit = {
        Description = "Mako notification daemon";
        PartOf = [ cfg.systemdTarget ];
      };
      Install = {
        WantedBy = [ cfg.systemdTarget ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${config.services.mako.package}/bin/mako";
        RestartSec = 5;
        Restart = "always";
      };
    };
  };
}
