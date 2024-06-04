{ config, lib, ... }:
let
  cfg = config.role.sshguard;
in
{
  options.role.sshguard.enable = lib.mkOption {
    default = true;
    description = "Wether to enable sshguard role";
    type = lib.types.bool;
  };

  config = lib.mkIf cfg.enable {
    services.sshguard = {
      enable = true;
      attack_threshold = 20;
      blacklist_threshold = 120;
      detection_time = 30 * 24 * 3600;
      whitelist = [
        "192.168.1.24"
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
