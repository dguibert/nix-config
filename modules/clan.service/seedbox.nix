{
  flake.aspects.seedbox."clan.service" = {
    manifest.name = "seedbox";

    roles.aria2.perInstance =
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

            services.aria2 = {
              enable = true;
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
          };
      };

    roles.qbittorrent.perInstance =
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
                pkgs.coreutils
              ];
              script = ''
                python3 ${./qbittorrent.Userpass.py} $(cat $prompts/password | tr -d \\n) > $out/password-hash
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
            networking.firewall.allowedTCPPorts = lib.mkIf (config.services.qbittorrent.enable) [
              config.services.qbittorrent.torrentingPort
            ];

            networking.firewall.allowedUDPPorts = lib.mkIf (config.services.qbittorrent.enable) [
              config.services.qbittorrent.torrentingPort
            ];

            networking.firewall.allowedTCPPortRanges = lib.mkIf (config.services.qbittorrent.enable) [
              {
                from = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMin;
                to = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMax;
              }
            ];
            networking.firewall.allowedUDPPortRanges = lib.mkIf (config.services.qbittorrent.enable) [
              {
                from = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMin;
                to = config.services.qbittorrent.serverConfig.BitTorrent.Session.OutgoingPortsMax;
              }
            ];
          };
      };

    roles.deluge.perInstance =
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
          };
      };

    roles.rtorrent.perInstance =
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
          let
            peer-port = 51412;
            web-port = 8112;
          in
          {
            my.persistence.directories = [
              "/var/lib/rtorrent/session"
              "/var/lib/flood"
            ];

            # seedbox
            services.rtorrent = {
              enable = true;
              openFirewall = true;
              dataPermissions = "0755";
              downloadDir = "/mnt/downloads2/rtorrent";
              port = peer-port;
              configText = ''
                #log.xmlrpc = (cat, (cfg.logs), "xmlrpc.log")
                network.bind_address.ipv4.set = "0.0.0.0"
                #network.bind_address.ipv6.set = "::"
                #network.local_address.ipv4.set =
                #network.local_address.ipv6.set =
              '';
            };
            services.flood = {
              enable = true;
              package = pkgs.flood.overrideAttrs (o: rec {
                version = "2025-12-25-unstable";

                src = pkgs.fetchFromGitHub {
                  owner = "jesec";
                  repo = "flood";
                  rev = "eeecb8e42a1cb6d6a736fc2078e673132d3849ff";
                  hash = "sha256-zpeNFVq0Mn0RxmChGLgt3eIKBbvUd6Iw+kL7d4sfLQ0=";
                };
                pnpmDeps = pkgs.fetchPnpmDeps {
                  inherit (o)
                    pname
                    ;
                  inherit version src;
                  pnpm = pkgs.pnpm_9;
                  fetcherVersion = 1;
                  hash = "sha256-4W0TT+HEuEGAgx9+IkCC78xjJqbqA4BX/SkZBfoZJoQ=";
                };
              });
              port = web-port;
              #            openFirewall = true;
              extraArgs = [ "--rtsocket=${config.services.rtorrent.rpcSocket}" ];
            };
            # allow access to the socket by putting it in the same group as rtorrent service
            # the socket will have g+w permissions
            systemd.services.flood.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
            systemd.services.flood.serviceConfig.DynamicUser = lib.mkForce false;

          };
      };
  };
}
