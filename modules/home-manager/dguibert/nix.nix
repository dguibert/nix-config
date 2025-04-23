{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  options.withNix.enable = (lib.mkEnableOption "Enable nix config") // {
    default = true;
  };

  config = lib.mkIf config.withNix.enable {
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
