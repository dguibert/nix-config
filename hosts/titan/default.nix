{ config, lib, inputs, withSystem, self, ... }:
{
  options.modules.hosts.titan = lib.mkOption {
    type = lib.types.listOf lib.types.raw;
    default = [ ./titan.nix ];
  };

  config.modules.hosts.titan = [
    ./titan.nix
    inputs.nix-ld.nixosModules.nix-ld

    # The module in this repository defines a new module under (programs.nix-ld.dev) instead of (programs.nix-ld)
    # to not collide with the nixpkgs version.
    { programs.nix-ld.dev.enable = true; }
    { environment.stub-ld.enable = false; } # conflict with nix-ld

    inputs.envfs.nixosModules.envfs
    { home-manager.users.dguibert = { imports = config.modules.homes."dguibert@titan"; }; }
    #{users.dguibert.with-home-manager = true;}
  ];

  config.flake.nixosConfigurations = withSystem "x86_64-linux" ({ system, ... }: {
    titan = inputs.self.lib.nixosSystem {
      inherit system;

      specialArgs = {
        pkgs = self.legacyPackages.${system};
        inherit inputs self;
      };
      modules = config.modules.hosts.titan;
    };
  });
}

