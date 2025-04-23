{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../common.nix
  ];
  services.rkvm.client = {
    enable = true;
    settings = {
      server = "${config.clan.rkvm.server}:${toString config.clan.rkvm.port}";
      certificate = config.clan.core.vars.generators.rkvm.files."rkvm-certificate.pem".path;
      password = config.sops.secrets."vars/rkvm/rkvm-password".key;
    };
  };
}
