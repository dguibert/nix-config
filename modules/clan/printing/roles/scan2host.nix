{ config, ... }:
{
  services.samba = {
    enable = true;
    securityType = "user";
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

}
