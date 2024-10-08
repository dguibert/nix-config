{ self, config, pkgs, lib, inputs, perSystem, ... }:
let
  l = lib // builtins;
  t = l.types;

  user_config = lib.importJSON inputs.config_json;

in
{
  options.user_config = lib.mkOption {
    description = "Attribute set of user config (loaded from config.yaml)";
    type = t.raw;
    default = { };
  };

  config.user_config = builtins.trace user_config user_config;
}
