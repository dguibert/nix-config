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
