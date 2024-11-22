{ self, config, pkgs, lib, inputs, withSystem, ... }:
let
  inherit (lib) concatMapStrings concatMapStringsSep head;
in
{
  options.modules.hosts.iso-aarch64 = lib.mkOption {
    type = lib.types.listOf lib.types.raw;
    default = [ ];
  };

  config.modules.hosts.iso-aarch64 = config.modules.hosts.iso ++ [
    ({ config, lib, pkgs, resources, ... }: {
      nixpkgs.localSystem.system = lib.mkForce "aarch64-linux";
    })
  ];

  config.flake.nixosConfigurations = withSystem "aarch64-linux" ({ system, ... }: {
    iso-aarch64 = inputs.self.lib.nixosSystem {
      inherit system;

      specialArgs = {
        pkgs = self.legacyPackages.${system};
        inherit inputs;
      };
      modules = config.modules.hosts.iso-aarch64;
    };
  });
}

