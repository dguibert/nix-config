{ config, lib, ... }:
let
  cfg = config.clan.sshguard;
in
{
  #options.clan.sshguard.option = lib.mkOption {
  #  default = true;
  #  description = "";
  #  type = lib.types.bool;
  #};

  config = {
    services.sshguard = {
      enable = true;
      services = [ "sshd" "sshd-session" ];
      attack_threshold = 10;
      blacklist_threshold = 10;
      detection_time = 30 * 24 * 3600;
      whitelist = [
        "192.168.1.24"
        "192.168.1.17"
        "10.147.27.0/24"
      ];
    };
    #systemd.tmpfiles.rules = [ "d /persist/var/lib/sshguard 1770 root root -" ];
    #systemd.tmpfiles.rules = [ "L /var/lib/sshguard/blacklist.db - - - - /persist/var/lib/sshguard/blacklist.db" ];

    # to prevent multiple authentication attempts during a single connection
    services.openssh.extraConfig = ''
      MaxAuthTries 2
    '';
  };
}
