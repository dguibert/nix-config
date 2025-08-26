{
  description = "A nixpkgs with overriden stdenv and overlays";

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
          config.replaceStdenv = import ./stdenv.nix;
        };

      dontCheck =
        pkg:
        pkg.overrideAttrs (o: {
          doCheck = false;
          doInstallCheck = false;
        });

      narHash =
        lib: pkg: version: hash:
        builtins.trace "${pkg.name} with new hash: ${hash}" lib.upgradeOverride pkg (_: {
          inherit version;
          src = pkg.src.overrideAttrs (_: {
            outputHash = hash;
          });
        });

    in
    {
      lib = nixpkgs.lib;

      overlays.default = final: prev: {
        nss_sss = prev.callPackage ./pkgs/sssd/nss-client.nix { };

        bind = dontCheck prev.bind;
        bmake = dontCheck prev.bmake;
        coreutils = dontCheck prev.coreutils;
        dbus = dontCheck prev.dbus;
        libffi = dontCheck prev.libffi;
        libuv = dontCheck prev.libuv;
        #nix = dontCheck prev.nix; # build-remote-input-addressed.sh... [FAIL]
        #nixStable = dontCheck prev.nixStable; # build-remote-input-addressed.sh... [FAIL]
        p11-kit = dontCheck prev.p11-kit;
        rsync = dontCheck prev.rsync; # FAIL    chgrp
        watchman = (dontCheck prev.watchman).overrideAttrs (o: {
          buildInputs = o.buildInputs ++ [ prev.gtest ];
        }); # CacheTest.future: malloc(): unaligned tcache chunk detected

        libseat = prev.seatd;

        svt-av1 = prev.svt-av1.overrideAttrs (o: {
          patches = [
            (prev.fetchpatch2 {
              url = "https://gitlab.com/AOMediaCodec/SVT-AV1/-/commit/ec699561b51f3204e2df6d4c2578eea1f7bd52be.patch?full_index=1";
              hash = "sha256-Y3DpWXfdEsXSzz9yhtvKUpvkwAsY1lYIP8daEgho5Gs=";
            })
          ];
        });
        pythonOverrides = prev.lib.composeOverlays [
          (prev.pythonOverrides or (_: _: { }))
          (python-self: python-super: {
            flasgger =
              (narHash prev.lib python-super.flasgger "0.9.7.1"
                "sha256-ULEf9DJiz/S2wKlb/vjGto8VCI0QDcm0pkU5rlOwtiE="
              ).overrideAttrs
                (o: {
                  patches = [ ];
                });
          })
        ];

        python313 = prev.python313.override { packageOverrides = final.pythonOverrides; };
      };

      legacyPackages.x86_64-linux = nixpkgsFor "x86_64-linux";
      legacyPackages.x86_64-darwin = nixpkgsFor "x86_64-darwin";
      legacyPackages.aarch64-linux = nixpkgsFor "aarch64-linux";
      legacyPackages.aarch64-darwin = nixpkgsFor "aarch64-darwin";
    };
}
