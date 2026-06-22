{
  lib,
  config,
  inputs,
  pkgs,
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
        options.crossCompilation = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      }
    );
  };

  config = {
    flake-file.inputs = {
      home-manager.url = "github:dguibert/home-manager/pu";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };
    flake = {
      lib.genProfile = user: name: profile: {
        path =
          pkgs.deploy-rs.lib.activate.custom config.flake.homeConfigurations."${name}".activationPackage
            ''
              ${
                if config.flake.homeConfigurations."${name}".config.home.sessionVariables ? NIX_STATE_DIR then
                  "export NIX_STATE_DIR=${
                    config.flake.homeConfigurations."${name}".config.home.sessionVariables.NIX_STATE_DIR
                  }"
                else
                  ""
              }
              ${
                if config.flake.homeConfigurations."${name}".config.home.sessionVariables ? NIX_STATE_DIR then
                  "export NIX_PROFILE=${
                    config.flake.homeConfigurations."${name}".config.home.sessionVariables.NIX_PROFILE
                  }"
                else
                  ""
              }
              ./activate
            '';
        sshUser = user;
        profilePath = "${builtins.dirOf builtins.storeDir}/var/nix/profiles/per-user/${user}/${profile}";
      };

      homeConfigurations = lib.flip lib.mapAttrs config.configurations.home (
        name:
        {
          module,
          system,
          crossCompilation,
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = if crossCompilation then pkgs.pkgsCross.${system} else config.flake.legacyPackages.${system};
          modules = [ module ];
        }
      );

      checks =
        config.flake.homeConfigurations
        |> lib.mapAttrsToList (
          name: home: {
            "${
              if config.configurations.home.${name}.crossCompilation then
                "x86_64-linux"
              else
                "${config.configurations.home.${name}.system}"
            }" =
              {
                "configurations/home/${name}" = home.config.home.activationPackage;
              };
          }
        )
        |> lib.mkMerge;
    };
  };
}
