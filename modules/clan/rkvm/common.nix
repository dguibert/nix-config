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

  config.clan.core.vars.generators.rkvm = {
    share = true;
    files.rkvm-certificate = { };
    files.rkvm-key = { };
    prompts.rkvm-password = { };
    runtimeInputs = [
      pkgs.rkvm
    ];
    script = ''
      rkvm-certificate-gen -i ${config.clan.rkvm.server} $out/rkvm-certificate $out/rkvm-key
    '';
  };
}
