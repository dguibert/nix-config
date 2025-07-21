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
            services.navidrome.openFirewall = true;
            services.navidrome.settings.Address = "192.168.1.24";
            services.navidrome.settings.Port = 4533;
            services.navidrome.settings.MusicFolder = "/home/dguibert/Music/mopidy";
          };
      };
  };
}
