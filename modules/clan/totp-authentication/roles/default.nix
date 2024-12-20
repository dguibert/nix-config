{ config, lib, ... }: {
  config = {
    security.pam.oath.enable = false;
    security.pam.services.sshd = { oathAuth = true; };
    security.pam.oath.usersFile = config.sops.secrets."oath-users-file".path;

    sops.secrets.oath-users-file = {
      owner = "root";
      mode = "600";
      path = "/etc/users.oath";
    };

    ## https://wiki.archlinux.org/title/Pam_oath
    services.openssh.settings.PasswordAuthentication = lib.mkForce true;
    services.openssh.extraConfig = ''
      ChallengeResponseAuthentication yes
    '';
  };

}
