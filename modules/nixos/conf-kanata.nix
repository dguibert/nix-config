{ config, lib, pkgs, ... }:
let
  cfg = config.conf-kanata;
in
{
  options.conf-kanata.enable = lib.mkOption {
    default = true;
    description = "Whether to enable kanata remapping keyboard keys";
    type = lib.types.bool;
  };

  config = lib.mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards = {
        internalKeyboard = {
          devices = [
            "/dev/input/by-id/usb-0557_2419-event-kbd"
            "/dev/input/by-id/usb-Dell_Dell_USB_Keyboard-event-kbd"
          ];
          extraDefCfg = "process-unmapped-keys yes";
          config = ''
            (defsrc
             caps q s d f j k l m
            )
            (defvar
             tap-time 150
             hold-time 200
            )
            (defalias
             caps (tap-hold 100 100 esc lctl)
             q (tap-hold $tap-time $hold-time a lmet)
             s (tap-hold $tap-time $hold-time s lalt)
             d (tap-hold $tap-time $hold-time d lsft)
             f (tap-hold $tap-time $hold-time f lctl)
             j (tap-hold $tap-time $hold-time j rctl)
             k (tap-hold $tap-time $hold-time k rsft)
             l (tap-hold $tap-time $hold-time l ralt)
             m (tap-hold $tap-time $hold-time ; rmet)
            )

            (deflayer base
             @caps @q  @s  @d  @f  @j  @k  @l  @m
            )
          '';
        };
      };
    };
  };
}
