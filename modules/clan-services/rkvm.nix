{
  _class = "clan.service";
  manifest.name = "printing";

  roles.client.interface =
    { lib, ... }:
    {
      options.rkvm.server = lib.mkOption {
        description = "Server address";
        type = lib.types.str;
      };

      options.rkvm.port = lib.mkOption {
        type = lib.types.port;
        description = "Server port";
        default = 5258;
      };

    };
  roles.client.perInstance =
    { settings, ... }:
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
              server = "${settings.rkvm.server}:${toString settings.rkvm.port}";
              certificate = config.clan.core.vars.generators.rkvm.files."rkvm-certificate.pem".path;
              password = config.sops.secrets."vars/rkvm/rkvm-password".key;
            };
          };
        };
    };

  roles.server.interface =
    { lib, ... }:
    {
      options.rkvm.server = lib.mkOption {
        description = "Server address";
        type = lib.types.str;
      };
      options.rkvm.port = lib.mkOption {
        type = lib.types.port;
        description = "Server port";
        default = 5258;
      };
    };
  roles.server.perInstance =
    { settings, ... }:
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
              listen = "${settings.rkvm.server}:${toString settings.rkvm.port}";
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
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
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
              rkvm-certificate-gen -i ${settings.rkvm.server} $out/rkvm-certificate.pem $out/rkvm-key.pem
              cat $prompts/rkvm-password > $out/rkvm-password
            '';
          };
        };
    };
}
