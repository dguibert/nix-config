{ inputs, lib, ... }: # resolved flake inputs as specialArgs
{
  # same inputs code as before
  flake-file.inputs = {
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    #allfollow.inputs.nixpkgs.follows = "nixpkgs";
    #allfollow.inputs.rust-overlay.follows = "rust-overlay";
    #rust-overlay.url = "github:oxalica/rust-overlay";

    # make sure you add flake-file dependency.
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";

    # To update all inputs:
    # $ nix flake update --recreate-lock-file

    #"nixos-18.03".url   = "github:nixos/nixpkgs-channels/nixos-18.03";
    #"nixos-18.09".url   = "github:nixos/nixpkgs-channels/nixos-18.09";
    #"nixos-19.03".url   = "github:nixos/nixpkgs-channels/nixos-19.03";

    gitignore = {
      url = "github:hercules-ci/gitignore";
      flake = false;
    };

    #nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
    # only needed if you use as a package set:

    #eww = {
    #  url = "github:elkowar/eww";
    #};
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    flake-compat.url = "github:edolstra/flake-compat";

  };

  imports = [
    # enable inside-flake and say goodbye to bootstrap
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.nix-auto-follow
    #inputs.flake-file.flakeModules.allfollow
  ];

  # generate the same output function we used at bootstrap
  #flake-file.outputs = "flake-parts";
  flake-file.outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";
}
