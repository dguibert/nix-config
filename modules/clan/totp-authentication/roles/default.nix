{ config, lib, ... }: {
  config = {
    security.pam.oath.enable = false;
    security.pam.services.sshd = { oathAuth = true; };
    security.pam.oath.usersFile = config.clan.core.vars.generators.oath-users.files.file.path;

    clan.core.vars.generators.oath-users = {
      share = true;
      # Option User Prefix Seed (openssl rand -hex 10)
      # oathtool -v --totp -d 6 12345678909876543210
      prompts.file = { };
    };

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
