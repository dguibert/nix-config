{ config, lib, pkgs, ... }:
{
  options.clan.rkvm.server = lib.mkOption {
    description = "Server address";
    type = lib.types.str;
  };

  options.clan.rkvm.port = lib.mkOption {
    type = lib.types.port;
    description = "Server port";
    default = 5258;
  };

  config = {
    sops.secrets.rkvm-certificate.sopsFile = ../../../secrets/defaults.yaml;
    sops.secrets.rkvm-key.sopsFile = ../../../secrets/defaults.yaml;
    sops.secrets.rkvm-password.sopsFile = ../../../secrets/defaults.yaml;
  };

}
