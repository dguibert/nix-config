{
  config,
  inputs,
  withSystem,
  self,
  ...
}:
let
  # platypush
  platypush = [
    (
      {
        config,
        lib,
        pkgs,
        inputs,
        ...
      }:
      {
        services.redis.servers."".enable = true;
      }
    )
  ];

  microvm = [
    inputs.microvm.nixosModules.host
    (
      {
        config,
        lib,
        pkgs,
        inputs,
        ...
      }:
      {
        role.microvm.enable = true;
      }
    )
  ];

  waydroid = [
    (
      {
        config,
        lib,
        pkgs,
        inputs,
        ...
      }:
      {
        virtualisation.waydroid.enable = true;
      }
    )
  ];

in
{ }
