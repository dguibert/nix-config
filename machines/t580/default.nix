{
  config,
  lib,
  inputs,
  withSystem,
  self,
  ...
}:
{
  options.modules.hosts.t580 = lib.mkOption {
    type = lib.types.listOf lib.types.raw;
    default = [ ];
  };

  config.modules.hosts.t580 = [
    ./configuration.nix
    {
      home-manager.users.dguibert = {
        imports = config.modules.homes."dguibert@t580";
      };
    }
  ];

  config.flake.nixosConfigurations = withSystem "x86_64-linux" (
    { system, ... }:
    {
      t580 = inputs.self.lib.nixosSystem {
        inherit system;

        specialArgs = {
          pkgs = self.legacyPackages.${system};
          inherit inputs;
        };
        modules = config.modules.hosts.t580;
      };
    }
  );
}
