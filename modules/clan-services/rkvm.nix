{
  _class = "clan.service";
  manifest.name = "printing";

  roles.default.perInstance =
    { ... }:
    {
      nixosModule =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          services.rkvm.client = {
            enable = true;
            settings = {
              server = "${config.clan.rkvm.server}:${toString config.clan.rkvm.port}";
              certificate = config.clan.core.vars.generators.rkvm.files."rkvm-certificate.pem".path;
              password = config.sops.secrets."vars/rkvm/rkvm-password".key;
            };
          };
        };
    };
  roles.default.perInstance =
    { ... }:
    {
      nixosModule =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          services.rkvm.server = {
            enable = true;
            settings = {
              listen = "${config.clan.rkvm.server}:${toString config.clan.rkvm.port}";
              switch-keys = [
                "middle"
                "left-ctrl"
              ];
              certificate = config.clan.core.vars.generators.rkvm.files."rkvm-certificate.pem".path;
              key = config.clan.core.vars.generators.rkvm.files."rkvm-key.pem".path;
              password = config.sops.secrets."vars/rkvm/rkvm-password".key;
            };
          };
          networking.firewall.allowedTCPPorts = [ 5258 ];
        };
    };

  perMachine =
    {
      instances,
      settings,
      machine,
      roles,
      ...
    }:
    {
      nixosModule =
        { config, ... }:
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
            files."rkvm-certificate.pem" = { };
            files."rkvm-key.pem" = { };
            files.rkvm-password = { };
            prompts.rkvm-password = { };
            runtimeInputs = [
              pkgs.rkvm
            ];
            script = ''
              rkvm-certificate-gen -i ${config.clan.rkvm.server} $out/rkvm-certificate.pem $out/rkvm-key.pem
              cat $prompts/rkvm-password > $out/rkvm-password
            '';
          };
        };
    };
}
