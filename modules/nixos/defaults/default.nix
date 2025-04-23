{
  config,
  lib,
  pkgs,
  resources,
  inputs,
  ...
}:
{
  imports = [
    inputs.nur_packages.inputs.nixpkgs.nixosModules.notDetected
    inputs.home-manager.nixosModules.home-manager
    ({
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs pkgs;
        sopsDecrypt_ = pkgs.sopsDecrypt_;
      };
    })
    (
      { config, ... }:
      {
        clan.core.networking.targetHost = config.clan.core.settings.machine.name;
      }
    )
    (
      {
        config,
        pkgsForSystem,
        system,
        ...
      }:
      {
        nixpkgs.hostPlatform = pkgsForSystem config.nixpkgs.system;
        nixpkgs.pkgs = pkgsForSystem config.nixpkgs.system;
      }
    )
    (
      { ... }:
      {
        programs.fuse.userAllowOther = true;
      }
    )

    ../distributed-build-conf.nix
    (
      { config, ... }:
      {
        distributed-build-conf.enable = true;
      }
    )
    ../nix-conf.nix
    (
      { config, ... }:
      {
        nix-conf.enable = true;
      }
    )
    ../report-changes.nix

    ../role-dns.nix
    ../role-microvm.nix
    ../conf-kanata.nix

    #../../modules/services.nix

    ../../../users/default.nix

    (
      { ... }:
      {
        documentation.nixos.enable = false;
      }
    )
    (
      { ... }:
      {
        programs.mosh.enable = true;
      }
    )
    ../impermanence.nix
  ];

  system.nixos.versionSuffix = lib.mkForce ".${
    lib.substring 0 8 (inputs.self.lastModifiedDate or inputs.self.lastModified or "19700101")
  }.${inputs.self.shortRev or "dirty"}";
  system.nixos.revision = lib.mkIf (inputs.self ? rev) (lib.mkForce inputs.self.rev);
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
  nix.settings.system-features =
    [ "recursive-nix" ]
    # default
    ++ [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ]
    ++ lib.optionals (config.nixpkgs ? localSystem && config.nixpkgs.localSystem ? system) [
      "gccarch-${
        builtins.replaceStrings [ "_" ] [ "-" ] (
          builtins.head (builtins.split "-" config.nixpkgs.localSystem.system)
        )
      }"
    ]
    ++ lib.optionals (pkgs.hostPlatform ? gcc.arch) (
      # a builder can run code for `gcc.arch` and inferior architectures
      [ "gccarch-${pkgs.hostPlatform.gcc.arch}" ]
      ++ map (x: "gccarch-${x}") lib.systems.architectures.inferiors.${pkgs.hostPlatform.gcc.arch}
    );

  environment.systemPackages = [
    pkgs.vim
    pkgs.git
  ];
  # Select internationalisation properties.
  console.font = "Lat2-Terminus16";
  console.keyMap = lib.mkDefault "fr";
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gtk2;

  # System wide: echo "@cert-authority * $(cat /etc/ssh/ca.pub)" >>/etc/ssh/ssh_known_hosts
  programs.ssh.knownHosts."*" = {
    certAuthority = true;
    publicKey = builtins.readFile ../../../secrets/ssh-ca-home.pub;
  };

  # time.cloudflare.com
  services.timesyncd.extraConfig = "FallbackNTP=162.159.200.1 2606:4700:f1::1";

  report-changes.enable = true;
}
