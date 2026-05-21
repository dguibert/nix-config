{
  config,
  inputs,
  lib,
  ...
}:
{
  options.flake.deploy.nodes = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    # TODO define a proper type
    #type = lib.types.lazyAttrsOf (
    #  lib.types.submodule {
    #    options.nodes = lib.mkOption {
    #      type = lib.types.attrsOf lib.types.raw;
    #    };
    #  }
    #);
  };

  config.perSystem =
    {
      pkgs,
      ...
    }:
    let
      drv = pkgs.deploy-rs.deploy-rs;
    in
    {
      apps.deploy = inputs.flake-utils.lib.mkApp {
        inherit drv;
        exePath = "/bin/deploy";
      };
    };
}
