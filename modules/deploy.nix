{ config, inputs, ... }:
{
  perSystem =
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
