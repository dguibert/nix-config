{ config, lib, ... }:
let
  name = config.clan.core.settings.machine.name;
in
{
  services.openssh.enable = true;
  services.openssh.listenAddresses = [
    { addr = "0.0.0.0"; port = 22322; }
  ];
  networking.firewall.allowedTCPPorts = [ 22322 ];
  services.openssh.startWhenNeeded = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.extraConfig = ''
    AcceptEnv COLORTERM
    Ciphers chacha20-poly1305@openssh.com,aes256-cbc,aes256-gcm@openssh.com,aes256-ctr
    KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
    MACs umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
  '';

  sops.age.sshKeyPaths = [
    "/root/.ssh/id_ed25519"
  ];

  clan.sshd.certificate.realms = [ ]
    ++ lib.optionals (name == "titan") [ "192.168.1.24" "10.147.27.24" ]
    ++ lib.optionals (name == "t580") [ "192.168.1.17" "10.147.27.17" ]
    ++ lib.optionals (name == "rpi31") [ "192.168.1.13" "10.147.27.13" ]
    ++ lib.optionals (name == "rpi41") [ "192.168.1.14" "10.147.27.14" "82.64.121.168" ]
  ;
}


