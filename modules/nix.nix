{ config, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      drv = pkgs.writeScriptBin "nix" (
        with pkgs;
        let
          name = "nix-${builtins.replaceStrings [ "/" ] [ "-" ] (builtins.dirOf builtins.storeDir)}";
          NIX_CONF_DIR =
            let
              nixConf = pkgs.writeTextDir "opt/nix.conf" ''
                sandbox = false
                auto-optimise-store = true
                allowed-users = *
                system-features = recursive-nix nixos-test benchmark big-parallel kvm
                sandbox-fallback = false
                keep-outputs = true       # Nice for developers
                keep-derivations = true   # Idem
                experimental-features = nix-command flakes recursive-nix ca-derivations
                system-features = recursive-nix nixos-test benchmark big-parallel gccarch-x86-64 kvm
                extra-platforms = i686-linux aarch64-linux
                store = local?store=${builtins.storeDir}&state=${builtins.dirOf builtins.storeDir}/state&log=${builtins.dirOf builtins.storeDir}/log'
              '';
            in
            "${nixConf}/opt";

        in
        ''
          #!${runtimeShell}
          export XDG_CACHE_HOME=$HOME/.cache/${name}
          export NIX_CONF_DIR=${NIX_CONF_DIR}
          $@
        ''
      );
    in
    {
      checks.app-nix = drv;
      apps.nix = inputs.flake-utils.lib.mkApp {
        inherit drv;
      };
    };

  flake.aspects.nix.nixos =
    { config, lib, ... }:
    {
      security.sudo.enable = true;
      security.sudo.wheelNeedsPassword = false;

      systemd.tmpfiles.rules = [
        "D! /tmp 1777 root root"
        "d /tmp 1777 root root 10d"
      ];

      zramSwap.enable = true;
      zramSwap.algorithm = "lzo";

      nix.settings.sandbox = true; # "relaxed";
      nix.settings.auto-optimise-store = true; # lib.mkForce false;
      #nix.optimise.automatic=true;
      nix.settings.keep-outputs = true; # Nice for developers
      nix.settings.keep-derivations = true; # Idem
      #extra-sandbox-paths = /opt/intel/licenses=/home/dguibert/nur-packages/secrets?
      #nix.settings.experimental-features = "ca-derivations recursive-nix";
      nix.settings.experimental-features = [ "recursive-nix" ];
      nix.settings.system-features = [
        "recursive-nix"
      ]
      # default
      ++ [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ]
      ++ lib.optionals (config.nixpkgs ? hostPlatform && config.nixpkgs.hostPlatform ? system) [
        "gccarch-${
          builtins.replaceStrings [ "_" ] [ "-" ] (
            builtins.head (builtins.split "-" config.nixpkgs.hostPlatform.system)
          )
        }"
      ]
      /*
        ++ lib.optionals (pkgs.hostPlatform ? gcc.arch) (
          # a builder can run code for `gcc.arch` and inferior architectures
          [ "gccarch-${pkgs.hostPlatform.gcc.arch}" ]
          ++ map (x: "gccarch-${x}") lib.systems.architectures.inferiors.${pkgs.hostPlatform.gcc.arch}
        )
      */
      ;
      nix.settings.binary-caches = [
        "https://cache.nixos.org"
        "https://r-ryantm.cachix.org"
        "https://arm.cachix.org"
        #"https://cache.ngi0.nixos.org/"
        #"https://nixos-rocm.cachix.org"
      ];
      nix.settings.binary-cache-public-keys = [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "r-ryantm.cachix.org-1:gkUbLkouDAyvBdpBX0JOdIiD2/DP1ldF3Z3Y6Gqcc4c="
        "arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM="
        #"cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
        # nixos-rocm.cachix.org-1:VEpsf7pRIijjd8csKjFNBGzkBqOmw8H9PRmgAq14LnE=
      ];
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
}
