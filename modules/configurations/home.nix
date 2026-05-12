{ lib, config, ... }:
{
  options.configurations.home = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
  };

  config.flake = {
    homeConfigurations = lib.flip lib.mapAttrs config.configurations.home (
      name: { module }: lib.nixosSystem { modules = [ module ]; }
    );

    checks =
      config.flake.homeConfigurations
      |> lib.mapAttrsToList (
        name: home: {
          ${home.config.nixpkgs.hostPlatform.system} = {
            "configurations/home/${name}" = home.config.activationPackage;
          };
        }
      )
      |> lib.mkMerge;
  };
}
