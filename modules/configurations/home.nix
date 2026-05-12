{
  lib,
  config,
  inputs,
  self,
  ...
}:
{
  options.configurations.home = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
        options.system = lib.mkOption {
          type = lib.types.str;
        };
      }
    );
  };

  config.flake = {
    homeConfigurations = lib.flip lib.mapAttrs config.configurations.home (
      name:
      { module, system }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = self.legacyPackages.${system};
        modules = [ module ];
      }
    );

    checks =
      config.flake.homeConfigurations
      |> lib.mapAttrsToList (
        name: home: {
          ${config.configurations.home.${name}.system} = {
            "configurations/home/${name}" = home.config.home.activationPackage;
          };
        }
      )
      |> lib.mkMerge;
  };
}
