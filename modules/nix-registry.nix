{
  lib,
  inputs,
  config,
  ...
}:
{
  flake.aspects.nix-registry.homeManager.imports = [
    config.flake.modules.nixos.nix-registry
  ];

  flake.aspects.nix-registry.nixos = {
    nix.registry = lib.mkForce (
      (lib.mapAttrs
        (id: flake: {
          inherit flake;
          from = {
            inherit id;
            type = "indirect";
          };
        })
        (
          builtins.removeAttrs inputs [
            "self"
            "nixpkgs"
          ]
        )
      )
      // {
        nixpkgs.from = {
          id = "nixpkgs";
          type = "indirect";
        };
        nixpkgs.flake = inputs.self // {
          lastModified = 0;
        };
      }
    );
  };
}
