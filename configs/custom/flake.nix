{
  description = "default user_config";

  outputs = { self, ... }: {
    flakeModule.user_config_settings = { ... }: {
      config.perSystem = { config, pkgs, lib, system, ... }: {
        user_config = lib.importJSON ./config.json;
      };
    };
  };
}
