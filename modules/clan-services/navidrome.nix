{
  _class = "clan.service";
  manifest.name = "navidrome";

  roles.server = {
    interface =
      { lib, ... }:
      {
        options = {
        };
      };

    perInstance =
      {
        instanceName,
        settings,
        machine,
        roles,
        ...
      }:
      {
        nixosModule =
          {
            config,
            lib,
            pkgs,
            inputs,
            ...
          }:
          {
            services.navidrome.enable = true;
            services.navidrome.settings.Address = "192.168.1.24";
            services.navidrome.settings.Port = 4533;
            services.navidrome.settings.MusicFolder = "/home/dguibert/Music";
            services.navidrome.settings.Jukebox.Enabled = true;
            services.navidrome.settings.MPVPath = "${pkgs.mpv}/bin/mpv";
            # List of registered devices, syntax:
            #  "symbolic name " - Symbolic name to be used in UI's
            #  "device" - MPV audio device name, do mpv --audio-device=help to get a list

            services.navidrome.settings.Jukebox.Devices = [
              # "symbolic name " "device"
              [
                "auto"
                "auto"
              ]
              [
                "jabra"
                "pipewire/alsa_output.usb-GN_Netcom_A_S_Jabra_EVOLVE_20_000BB222073E0A-00.analog-stereo"
              ]
            ];

            # Device to use for Jukebox mode, if there are multiple entries above.
            # Using device "auto" if missing
            services.navidrome.settings.Jukebox.Default = "auto";

            services.navidrome.user = "dguibert";
            systemd.services.navidrome = {
              serviceConfig.PrivateUsers = lib.mkForce false;
              serviceConfig.PermissionsStartOnly = true;
              serviceConfig.ProtectHome = lib.mkForce false;
              unitConfig.RequiresMountsFor = "/home/dguibert/Music";
            };
            services.navidrome.openFirewall = true;
            #networking.firewall.interfaces."bond0".allowedTCPPorts = [
            #  config.services.navidrome.settings.Port
            #];
          };
      };
  };
}
