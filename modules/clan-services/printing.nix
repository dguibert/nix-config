{
  _class = "clan.service";
  manifest.name = "printing";

  roles.default.perInstance =
    { ... }:
    {
      nixosModule =
        { ... }:
        # from https://www.pwg.org/ipp/everywhere.html
        {
          # Most printers manufactured after 2013 support the IPP Everywhere protocol
          # https://www.pwg.org/ipp/everywhere.html
          services.avahi = {
            enable = true;
            nssmdns4 = true;
            openFirewall = true;
          };

          services.printing.enable = true;
          hardware.printers = {
            ensureDefaultPrinter = "OKI_MC363_C1E8FC";
            ensurePrinters = [
              {
                deviceUri = "ipp://192.168.1.100:631/ipp/print";
                location = "home";
                name = "OKI_MC363_C1E8FC";
                model = "everywhere";
              }
            ];
          };
        };
    };

  roles.scan2host.perInstance =
    { ... }:
    {
      nixosModule =
        { config, ... }:
        {
          services.samba = {
            enable = true;
            settings = {
              global = {
                "workgroup" = "ORSIN";
                "server string" = config.clan.core.settings.machine.name;
                "netbios name" = config.clan.core.settings.machine.name;
                "security" = "user";
                #"use sendfile" = "yes";
                #"max protocol" = "smb2";
                # note: localhost is the ipv6 localhost ::1
                "hosts allow" = "192.168.1. 127.0.0.1 localhost";
                "hosts deny" = "0.0.0.0/0";
                "guest account" = "nobody";
                "map to guest" = "bad user";
              };
              "scans" = {
                "path" = "/mnt/scans";
                "browseable" = "yes";
                "read only" = "no";
                "guest ok" = "yes";
                "create mask" = "0644";
                "directory mask" = "0755";
                #"force user" = "username";
                #"force group" = "groupname";
              };
            };
          };

          networking.firewall.allowedTCPPorts = [
            445
            139
          ];
          networking.firewall.allowedUDPPorts = [
            137
            138
          ];

          systemd.tmpfiles.rules = [
            "d /mnt/scans 1777 root root -"
          ];

          services.samba-wsdd = {
            enable = true;
            openFirewall = true;
          };

        };
    };
}
