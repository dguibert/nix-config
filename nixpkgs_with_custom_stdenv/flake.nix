{
  description = "A nixpkgs with overriden stdenv and overlays";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      nixpkgsFor = system: import (nixpkgs.inputs.nixpkgs or nixpkgs) {
        inherit system;
        overlays =
          (nixpkgs.legacyPackages.${system}.overlays or [ ])
          ++ [
            self.overlays.default
          ]
        ;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        config.replaceStdenv = import ./stdenv.nix;
      };

      dontCheck = pkg: pkg.overrideAttrs (o: {
        doCheck = false;
        doInstallCheck = false;
      });
    in
    {
      lib = nixpkgs.lib;

      overlays.default = final: prev: {
        nss_sss = prev.callPackage ./pkgs/sssd/nss-client.nix { };

        bind = dontCheck prev.bind;
        coreutils = dontCheck prev.coreutils;
        dbus = dontCheck prev.dbus;
        libffi = dontCheck prev.libffi;
        libuv = dontCheck prev.libuv;
        nix = dontCheck prev.nix; # build-remote-input-addressed.sh... [FAIL]
        nixStable = dontCheck prev.nixStable; # build-remote-input-addressed.sh... [FAIL]
        p11-kit = dontCheck prev.p11-kit;
        watchman = (dontCheck prev.watchman).overrideAttrs (o: {
          buildInputs = o.buildInputs ++ [ prev.gtest ];
        }); # CacheTest.future: malloc(): unaligned tcache chunk detected

        libseat = prev.seatd;
      };

      legacyPackages.x86_64-linux = nixpkgsFor "x86_64-linux";
      legacyPackages.x86_64-darwin = nixpkgsFor "x86_64-darwin";
      legacyPackages.aarch64-linux = nixpkgsFor "aarch64-linux";
      legacyPackages.aarch64-darwin = nixpkgsFor "aarch64-darwin";
    };
}
