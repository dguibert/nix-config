{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom-foot;
in
with lib;
{
  options.custom-foot.enable = (lib.mkEnableOption "Enable custom foot config") // {
    default = false;
  };

  config = lib.mkIf cfg.enable {
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
  };
}
