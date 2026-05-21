{
  flake.aspects.sshd.nixos = {
    services.openssh.enable = true;

    services.openssh.listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 22322;
      }
      {
        addr = "[::]";
        port = 22322;
      }
    ];
    systemd.sockets.sshd.socketConfig.BindIPv6Only = "ipv6-only";

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
  };

}
