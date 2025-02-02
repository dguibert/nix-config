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
      certificate = config.clan.core.vars.generators.rkvm.files."rkvm-certificate.pem".path;
      key = config.clan.core.vars.generators.rkvm.files."rkvm-key.pem".path;
      password = config.sops.secrets."vars/rkvm/rkvm-password".key;
    };
  };
}
