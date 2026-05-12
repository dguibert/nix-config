{ inputs, lib, ... }: # resolved flake inputs as specialArgs
{
  # same inputs code as before
  flake-file.inputs = {
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nur_packages/nixpkgs";

    # make sure you add flake-file dependency.
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";

    # To update all inputs:
    # $ nix flake update --recreate-lock-file
    home-manager.url = "github:dguibert/home-manager/pu";
    home-manager.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

    #nix.follows = "nur_packages/nix";
    nix.url = "github:dguibert/nix/pu";

    sops-nix.url = "github:dguibert/sops-nix/pu"; # for dg/use-with-cross-system
    sops-nix.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

    #nixpkgs.url = "path:nixpkgs";
    nixpkgs.url = "github:dguibert/nix-config?dir=nixpkgs";
    nixpkgs.inputs.nixpkgs.follows = "nur_packages";
    upstream_nixpkgs.url = "github:dguibert/nixpkgs/pu";
    nur_packages.url = "github:dguibert/nur-packages?ref=master";
    nur_packages.inputs.nixpkgs.follows = "upstream_nixpkgs";
    nur_packages.inputs.nix.inputs.flake-compat.follows = "flake-compat";

    disko.url = "github:nix-community/disko";
    #disko.url = github:dguibert/disko;
    disko.inputs.nixpkgs.follows = "nixpkgs";

    terranix = {
      url = "github:mrVanDalo/terranix";
      flake = false;
    };
    #"nixos-18.03".url   = "github:nixos/nixpkgs-channels/nixos-18.03";
    #"nixos-18.09".url   = "github:nixos/nixpkgs-channels/nixos-18.09";
    #"nixos-19.03".url   = "github:nixos/nixpkgs-channels/nixos-19.03";
    stylix.url = "github:danth/stylix";
    stylix.inputs.base16.follows = "base16";
    stylix.inputs.base16-vim.follows = "base16-vim";
    stylix.inputs.flake-parts.follows = "flake-parts";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.systems.follows = "systems";

    base16.url = "github:SenchoPens/base16.nix";
    #base16.inputs.nixpkgs.follows = "nixpkgs";
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
    nxsession.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
    nxsession.inputs.flake-utils.follows = "nur_packages/flake-utils";

    # For accessing `deploy-rs`'s utility Nix functions
    deploy-rs.url = "github:dguibert/deploy-rs/pu";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
    deploy-rs.inputs.flake-compat.follows = "flake-compat";
    deploy-rs.inputs.utils.follows = "nur_packages/flake-utils";

    #nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
    # only needed if you use as a package set:
    #nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
    #nixpkgs-wayland.inputs.master.follows = "master";
    #emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.follows = "nur_packages/emacs-overlay";

    flake-utils.follows = "nur_packages/flake-utils";

    #hyprland.url = "github:hyprwm/Hyprland";
    hyprland.url = "git+https://github.com/dguibert/Hyprland?ref=refs/heads/main&submodules=1";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.inputs.systems.follows = "systems";
    hyprland.inputs.pre-commit-hooks.follows = "git-hooks-nix";
    hyprsplit.url = "github:dguibert/hyprsplit";
    hyprsplit.inputs.hyprland.follows = "hyprland";

    hyprland-contrib.url = "github:hyprwm/contrib";

    #eww = {
    #  url = "github:elkowar/eww";
    #  nixpkgs.follows = "nur_packages";
    #  rust-overlay.follows = "rust-overlay";
    #};
    nix-ld.url = "github:Mic92/nix-ld";
    # this line assume that you also have nixpkgs as an input
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    envfs.url = "github:Mic92/envfs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    impermanence.url = "github:nix-community/impermanence";
    #impermanence.url = "github:dguibert/impermanence";

    microvm.url = "github:astro/microvm.nix";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs/nixpkgs";

    flake-compat.url = "github:edolstra/flake-compat";

  };

  imports = [
    # enable inside-flake and say goodbye to bootstrap
    inputs.flake-file.flakeModules.default

    # start splitting from inputs.nix into other files
  ];

  # generate the same output function we used at bootstrap
  #flake-file.outputs = "flake-parts";
  flake-file.outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";
}
