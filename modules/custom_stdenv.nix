{ lib, ... }:
let
  custom_config = {
    replaceStdenv = builtins.trace "custom_stdenv" import custom_stdenv/_stdenv.nix;
  };
  dontCheck =
    pkg:
    pkg.overrideAttrs (o: {
      doCheck = false;
      doInstallCheck = false;
    });

  narHash =
    lib: pkg: version: hash:
    builtins.trace "${pkg.name} with new hash: ${hash}" upgradeOverride pkg (_: {
      inherit version;
      src = pkg.src.overrideAttrs (_: {
        outputHash = hash;
      });
    });

  composeOverlays = lib.foldl' lib.composeExtensions (self: super: { });
  upgradeOverride =
    package: overrides:
    let
      upgraded = package.overrideAttrs overrides;
    in
    (upgradeReplace package upgraded);

  upgradeReplace =
    package: upgraded:
    let
      upgradedVersion = (builtins.parseDrvName upgraded.name).version;
      originalVersion = (builtins.parseDrvName package.name).version;

      isDowngrade = (builtins.compareVersions upgradedVersion originalVersion) == -1;

      warn = builtins.trace "Warning: ${package.name} downgraded by overlay with ${upgraded.name}.";
      pass = x: x;
    in
    (if isDowngrade then warn else pass) upgraded;

  overlays = [
    (final: prev: {
      nss_sss = prev.callPackage ./custom_stdenv/_nss-client.nix { };

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

      pythonOverrides = composeOverlays [
        (prev.pythonOverrides or (_: _: { }))
        (python-self: python-super: {
          flasgger =
            (narHash prev.lib python-super.flasgger "0.9.7.1"
              "sha256-ULEf9DJiz/S2wKlb/vjGto8VCI0QDcm0pkU5rlOwtiE="
            ).overrideAttrs
              (o: {
                patches = [ ];
                doCheck = false;
                doInstallCheck = false;
              });
        })
      ];

      python313 = prev.python313.override { packageOverrides = final.pythonOverrides; };
    })
  ];
in
{
  # https://flake.parts/system
  flake.aspects.custom_stdenv.nixos = {
    nixpkgs.config = custom_config;
    nixpkgs.overlays = overlays;
  };

  flake.aspects.custom_stdenv.homeManager = {
    nixpkgs.config = custom_config;
    nixpkgs.overlays = overlays;
  };
}
