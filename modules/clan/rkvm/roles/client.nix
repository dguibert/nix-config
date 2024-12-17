{ config, lib, pkgs, ... }:
{
  imports = [
    ../common.nix
  ];
  services.rkvm.client = {
    enable = true;
    settings = {
      server = "${config.role-rkvm.server}:${config.role-rkvm.port}";
      certificate = config.sops.secrets.rkvm-certificate.path;
      password = config.sops.secrets.rkvm-password.key;
    };
  };
}
