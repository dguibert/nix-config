{ self, config, pkgs, lib, inputs, perSystem, ... }:
let
  l = lib // builtins;
  t = l.types;

in
{
  config.perSystem = args@{ config, pkgs, system, ... }: {
    options.user_config = lib.mkOption {
      description = "Attribute set of user config";
      type = t.raw;
      default = { };
    };
  };
}
