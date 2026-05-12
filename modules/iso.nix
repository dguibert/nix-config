{
  self,
  config,
  pkgs,
  lib,
  inputs,
  withSystem,
  ...
}:
let
  inherit (lib) concatMapStrings concatMapStringsSep head;
in
{
  config.configurations.nixos.iso.module = {
    imports = [
      (import "${inputs.nur_packages.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      config.flake.modules.nixos.zfs
      ({
        zfs-conf.enable = true;
        nixpkgs.hostPlatform.system = "x86_64-linux";
        networking.wireless.interfaces = [ "wlan0" ];
      })
      (
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          boot.supportedFilesystems = [ "zfs" ];
          services.openssh.enable = true;
          services.openssh.startWhenNeeded = true;
          # Select internationalisation properties.
          console.font = "Lat2-Terminus16";
          console.keyMap = "fr";
          i18n.defaultLocale = "en_US.UTF-8";
          console.earlySetup = true;

          # Set your time zone.
          time.timeZone = "Europe/Paris";

          environment.systemPackages = [
            pkgs.vim
          ];
        }
      )
    ];
  };
}
