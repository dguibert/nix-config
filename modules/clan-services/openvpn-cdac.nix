{
  _class = "clan.service";
  manifest.name = "openvpn-cdac";

  roles.default = {
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
            systemd.services."netns@" = {
              description = "%I network namespace";
              before = [ "network.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
                ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
              };
            };

            systemd.services.openvpn-cdac.bindsTo = [ "netns@cdac.service" ];
            #systemd.services. ....bindsTo = [ "netns@cdac.service" ];
            clan.core.vars.generators.openvpn-cdac = {
              prompts.config.persist = true;
              prompts.config.type = "multiline";
              prompts.credentails.persist = true;
              prompts.credentails.type = "multiline";
            };

            services.openvpn.servers = {
              cdac = {
                #up = ''
                # ${pkgs.iproute2}/bin/ip link set tun0 netns cdac
                #'';
                #down = ''
                #'';
                config = ''
                  config ${config.clan.core.vars.generators.openvpn-cdac.files.config.path}
                  auth-user-pass ${config.clan.core.vars.generators.openvpn-cdac.files.credentails.path}
                '';
              };
            };
          };
      };
  };
}
