{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  options.withZellij.enable = (lib.mkEnableOption "Enable Zellij config"); # // { default = true; };

  config = lib.mkIf config.withZellij.enable (
    lib.mkMerge [
      ({
        programs.zellij.enable = true;

        programs.zellij.enableBashIntegration = false;
        programs.zellij.settings = {
          keybinds = {
            unbind = "Ctrl q"; # unbind in all modes

            locked = {
              unbind = "Ctrl g";
              bind = {
                _args = [ "Alt g" ];
                SwitchToMode = "normal";
              };
            };
          };

          # default_layout "compact"
          default_mode = "locked";
          copy_command = "wl-copy";
          pane_frames = false;
          # copy_clipboard "primary"

          pane = {
            _args = [
              "size = 1"
              "borderless = true"
            ];
            plugin = {
              _props = {
                location = "zellij:compact-bar";
              };
            };
          };
        };
      })

      (lib.mkIf config.withStylixTheme.enable ({
        programs.zellij.settings = {
          theme = "stylix";
          themes.stylix = with config.lib.stylix.colors.withHashtag; {
            bg = base03;
            fg = base05;
            red = base08;
            green = base0B;
            blue = base0D;
            yellow = base0A;
            magenta = base0E;
            orange = base09;
            cyan = base0C;
            black = base00;
            white = base07;
          };
        };
      }))
    ]
  );
}
