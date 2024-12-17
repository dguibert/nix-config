{ config, lib, pkgs, ... }:
{
  imports = [
    ../common.nix
  ];
  services.rkvm.server = {
    enable = true;
    settings = {
      listen = "${config.clan.rkvm.server}:${toString config.clan.rkvm.port}";
      switch-keys = [ "middle" "left-ctrl" ];
      certificate = config.sops.secrets.rkvm-certificate.path;
      key = config.sops.secrets.rkvm-key.path;
      password = config.sops.secrets.rkvm-password.key;
    };
  };
}
