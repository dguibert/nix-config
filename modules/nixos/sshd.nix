{ config, ... }:
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

  # don't set ssh_host_rsa_key since userd by sops to decrypt secrets
  #sops.secrets."ssh_host_ed25519_key"          .path = "/persist/etc/ssh/ssh_host_ed25519_key";
  #sops.secrets."ssh_host_ed25519_key.pub"      .path = "/persist/etc/ssh/ssh_host_ed25519_key.pub";
  #sops.secrets."ssh_host_ed25519_key-cert.pub" .path = "/persist/etc/ssh/ssh_host_ed25519_key-cert.pub";

  #services.openssh.hostKeys = [
  #  {
  #    #path = config.sops.secrets."ssh_host_ed25519_key".path;
  #    path = "/persist/etc/ssh/ssh_host_ed25519_key";
  #    type = "ed25519";
  #    round = 100;
  #  }
  #];

  programs.ssh.knownHosts.ssh-ca-no-domain = {
    certAuthority = true;
    extraHostNames = [ "*" ];
    publicKey = config.clan.core.vars.generators.openssh-ca.files."id_ed25519.pub".value;
  };
}


