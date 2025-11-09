{
  _class = "clan.service";
  manifest.name = "seedbox";

  roles.default = { };

  perMachine =
    {
      instances,
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
          ...
        }:
        {
          clan.core.vars.generators.aria2 = {
            files.rpc-secret-file.deploy = true;
            runtimeInputs = [
              pkgs.xkcdpass
            ];
            script = ''
              xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > $out/rpc-secret-file
            '';
          };
          # seedbox
          services.deluge = {
            enable = false;
            openFirewall = true;
            #declarative = true;
            config = {
              download_location = "/mnt/downloads";
              allow_remote = true;
              daemon_port = 58846;
              listen_ports = [
                6881
                6889
              ];
            };
            web.enable = true;
          };

          services.aria2 = {
            enable = false;
            openPorts = true;
            serviceUMask = "0002";
            rpcSecretFile = config.clan.core.vars.generators.aria2.files.rpc-secret-file.path;
            settings = {
              #dir = "";
              seed-ratio = "0.0";
              disk-cache = 0;
              file-allocation = "none";
              check-integrity = true;
              always-resume = true;
              #continue=true;
              remote-time = true;

              peer-id-prefix = "-qB5120-";
              peer-agent = "qBittorrent/5.1.2";

            };
          };

          my.persistence.directories = [
            "/var/lib/qBittorrent"
          ];

          clan.core.vars.generators.qbittorrent = {
            prompts.user.persist = true;
            files.user.secret = false;
            prompts.password.type = "hidden";
            files.password-hash.secret = false;
            runtimeInputs = [
              pkgs.python3
            ];
            script = ''
              python3 ${./qbittorrent.Userpass.py} $(echo $prompts/password) > $out/password-hash
            '';
          };

          services.qbittorrent = {
            enable = true;
            webuiPort = 8081;
            torrentingPort = 20556;
            extraArgs = [
              "--confirm-legal-notice"
            ];

            serverConfig = {
              BitTorrent.Session = {
                BTProtocol = "TCP";
                DefaultSavePath = "/mnt/downloads2";
                DHTEnabled = false;
                IDNSupportEnabled = true;
                MaxConnections = -1;
                MaxConnectionsPerTorrent = -1;
                MaxUploads = -1;
                MaxUploadsPerTorrent = -1;
                OutgoingPortsMax = 6999;
                OutgoingPortsMin = 6881;
                PeXEnabled = false;
                #Port=20556;
                #SSRFMitigation = false;
                uTPRateLimited = false;
                QueueingSystemEnabled = false;
              };
              Network.PortForwardingEnabled = false;
              Preferences = {
                WebUI = {
                  #    AlternativeUIEnabled = true;
                  #    RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
                  Username = config.clan.core.vars.generators.qbittorrent.files.user.value;
                  Password_PBKDF2 = "@ByteArray(${
                    config.clan.core.vars.generators.qbittorrent.files."password-hash".value
                  })";
                };
              };
            };
          };
          systemd.services.qbittorrent.serviceConfig.BindPaths = [
            "/mnt/downloads2"
          ];
          networking.firewall.allowedTCPPorts = [
            config.services.qbittorrent.torrentingPort
          ];

          networking.firewall.allowedUDPPorts = [
            config.services.qbittorrent.torrentingPort
          ];

          networking.firewall.allowedTCPPortRanges = [
            {
              from = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMin;
              to = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMax;
            }
          ];
          networking.firewall.allowedUDPPortRanges = [
            {
              from = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMin;
              to = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMax;
            }
          ];
        };
    };
}
