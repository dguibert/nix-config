# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Configurations of my systems";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    extra-experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };

  inputs = {
    base16-shell = {
      url = "github:tinted-theming/tinted-shell";
      flake = false;
    };
    base16-vim = {
      url = "github:tinted-theming/base16-vim";
      flake = false;
    };
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.sops-nix.follows = "sops-nix";
    };
    deploy-rs.url = "github:dguibert/deploy-rs/pu";
    envfs = {
      url = "github:Mic92/envfs";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    flake-aspects.url = "github:vic/flake-aspects";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    gitignore = {
      url = "github:hercules-ci/gitignore";
      flake = false;
    };
    home-manager = {
      url = "github:dguibert/home-manager/pu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    import-tree.url = "github:vic/import-tree";
    microvm.url = "github:astro/microvm.nix";
    nix-auto-follow = {
      url = "github:fzakaria/nix-auto-follow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixpkgs.url = "github:dguibert/nixpkgs/pu";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nur_packages.url = "github:dguibert/nur-packages?ref=master";
    nxsession = {
      url = "github:dguibert/nxsession";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    sops-nix = {
      url = "github:dguibert/sops-nix/pu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    systems.url = "github:nix-systems/default-linux";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    tt-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };
}
