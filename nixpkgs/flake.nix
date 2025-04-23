{
  description = "A nixpkgs with overlays";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      nixpkgsFor =
        system:
        import (nixpkgs.inputs.nixpkgs or nixpkgs) {
          inherit system;
          overlays = (nixpkgs.legacyPackages.${system}.overlays or [ ]) ++ [
            self.overlays.default
          ];
          config.allowUnfree = true;
          config.allowUnsupportedSystem = true;
        };
    in
    {
      lib = nixpkgs.lib;

      overlays.default = final: prev: { };

      legacyPackages.x86_64-linux = nixpkgsFor "x86_64-linux";
      legacyPackages.x86_64-darwin = nixpkgsFor "x86_64-darwin";
      legacyPackages.aarch64-linux = nixpkgsFor "aarch64-linux";
      legacyPackages.aarch64-darwin = nixpkgsFor "aarch64-darwin";
    };
}
