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

            services.navidrome.user = "dguibert";
            systemd.services.navidrome = {
              serviceConfig.PrivateUsers = lib.mkForce false;
              serviceConfig.PermissionsStartOnly = true;
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
