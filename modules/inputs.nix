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
    home-manager.url = "github:dguibert/home-manager/pu";

    nix.url = "github:dguibert/nix/pu";

    sops-nix.url = "github:dguibert/sops-nix/pu"; # for dg/use-with-cross-system

    nixpkgs.url = "github:dguibert/nixpkgs/pu";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nur_packages.url = "github:dguibert/nur-packages?ref=master";

    disko.url = "github:nix-community/disko";
    #disko.url = github:dguibert/disko;

    terranix = {
      url = "github:mrVanDalo/terranix";
      flake = false;
    };
    #"nixos-18.03".url   = "github:nixos/nixpkgs-channels/nixos-18.03";
    #"nixos-18.09".url   = "github:nixos/nixpkgs-channels/nixos-18.09";
    #"nixos-19.03".url   = "github:nixos/nixpkgs-channels/nixos-19.03";
    stylix.url = "github:danth/stylix";

    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    base16-vim = {
      url = "github:tinted-theming/base16-vim";
      flake = false;
    };
    base16-shell = {
      url = "github:tinted-theming/tinted-shell";
      flake = false;
    };
    gitignore = {
      url = "github:hercules-ci/gitignore";
      flake = false;
    };

    nxsession.url = "github:dguibert/nxsession";

    # For accessing `deploy-rs`'s utility Nix functions
    deploy-rs.url = "github:dguibert/deploy-rs/pu";

    #nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
    # only needed if you use as a package set:

    #hyprland.url = "github:hyprwm/Hyprland";
    hyprland.url = "git+https://github.com/dguibert/Hyprland?ref=refs/heads/main&submodules=1";
    hyprsplit.url = "github:dguibert/hyprsplit";

    hyprland-contrib.url = "github:hyprwm/contrib";

    #eww = {
    #  url = "github:elkowar/eww";
    #};
    nix-ld.url = "github:Mic92/nix-ld";
    # this line assume that you also have nixpkgs as an input

    envfs.url = "github:Mic92/envfs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    impermanence.url = "github:nix-community/impermanence";
    #impermanence.url = "github:dguibert/impermanence";

    microvm.url = "github:astro/microvm.nix";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    flake-compat.url = "github:edolstra/flake-compat";

  };

  imports = [
    # enable inside-flake and say goodbye to bootstrap
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.nix-auto-follow
    #inputs.flake-file.flakeModules.allfollow

    # start splitting from inputs.nix into other files
  ];

  # generate the same output function we used at bootstrap
  #flake-file.outputs = "flake-parts";
  flake-file.outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";
}
