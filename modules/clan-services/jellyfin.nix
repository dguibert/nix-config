{
  _class = "clan.service";
  manifest.name = "jellyfin";

  roles.default.perInstance =
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
          config = {
            services.jellyfin.enable = true;
            services.jellyfin.user = "dguibert";
            systemd.services.jellyfin = lib.mkIf config.services.jellyfin.enable {
              serviceConfig.PrivateUsers = lib.mkForce false;
              serviceConfig.PermissionsStartOnly = true;
              #preStart = ''
              #  set -x
              #  #${pkgs.acl}/bin/setfacl -Rm u:jellyfin:rwX,m:rw-,g:jellyfin:rwX,d:u:jellyfin:rwX,d:g:jellyfin:rwX,o:---,d:o:---,d:m:rwx,m;rwx /home/dguibert/Videos/Series/ /home/dguibert/Videos/Movies/
              #  ${pkgs.acl}/bin/setfacl -m user:jellyfin:r-x /home/dguibert
              #  ${pkgs.acl}/bin/setfacl -m user:jellyfin:r-x /home/dguibert/Videos
              #  ${pkgs.acl}/bin/setfacl -m user:jellyfin:rwx /home/dguibert/Videos/Series
              #  ${pkgs.acl}/bin/setfacl -m user:jellyfin:rwx /home/dguibert/Videos/Movies
              #  ${pkgs.acl}/bin/setfacl -m group:jellyfin:r-x /home/dguibert
              #  ${pkgs.acl}/bin/setfacl -m group:jellyfin:r-x /home/dguibert/Videos
              #  ${pkgs.acl}/bin/setfacl -m group:jellyfin:rwx /home/dguibert/Videos/Series
              #  ${pkgs.acl}/bin/setfacl -m group:jellyfin:rwx /home/dguibert/Videos/Movies
              #  set +x
              #'';
              unitConfig.RequiresMountsFor = "/home/dguibert/Videos";
            };
            networking.firewall.interfaces."bond0".allowedTCPPorts = [
              8096 # http
              8920 # https
            ];
            systemd.tmpfiles.rules = [
              "L /var/lib/jellyfin/config - - - - /persist/var/lib/jellyfin/config"
              "L /var/lib/jellyfin/data   - - - - /persist/var/lib/jellyfin/data"
            ];

          };
        };
    };
}
