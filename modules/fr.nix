{ lib, ... }:
{
  flake.aspects.fr.nixos = {
    # Select internationalisation properties.
    console.font = "Lat2-Terminus16";
    console.keyMap = lib.mkDefault "fr";
    i18n.defaultLocale = "en_US.UTF-8";

    # Set your time zone.
    time.timeZone = "Europe/Paris";
  };
}
