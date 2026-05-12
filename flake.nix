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
    base16.url = "github:SenchoPens/base16.nix";
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
      inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
    };
    deploy-rs = {
      url = "github:dguibert/deploy-rs/pu";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs/nixpkgs";
        utils.follows = "nur_packages/flake-utils";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.follows = "nur_packages/emacs-overlay";
    envfs.url = "github:Mic92/envfs";
    flake-aspects.url = "github:vic/flake-aspects";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nur_packages/nixpkgs";
    };
    flake-utils.follows = "nur_packages/flake-utils";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs/nixpkgs/nixpkgs";
      };
    };
    gitignore = {
      url = "github:hercules-ci/gitignore";
      flake = false;
    };
    home-manager = {
      url = "github:dguibert/home-manager/pu";
      inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/dguibert/Hyprland?ref=refs/heads/main&submodules=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "git-hooks-nix";
        systems.follows = "systems";
      };
    };
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprsplit = {
      url = "github:dguibert/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    microvm.url = "github:astro/microvm.nix";
    nix.url = "github:dguibert/nix/pu";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixpkgs = {
      url = "github:dguibert/nix-config?dir=nixpkgs";
      inputs.nixpkgs.follows = "nur_packages";
    };
    nur_packages = {
      url = "github:dguibert/nur-packages?ref=master";
      inputs = {
        git-hooks-nix.follows = "git-hooks-nix";
        nix.inputs.flake-compat.follows = "flake-compat";
        nixpkgs.follows = "upstream_nixpkgs";
      };
    };
    nxsession = {
      url = "github:dguibert/nxsession";
      inputs = {
        flake-utils.follows = "nur_packages/flake-utils";
        nixpkgs.follows = "nixpkgs/nixpkgs";
      };
    };
    sops-nix = {
      url = "github:dguibert/sops-nix/pu";
      inputs.nixpkgs.follows = "nur_packages/nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        base16.follows = "base16";
        base16-vim.follows = "base16-vim";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    systems.url = "github:nix-systems/default-linux";
    terranix = {
      url = "github:mrVanDalo/terranix";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs/nixpkgs";
    };
    tt-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    upstream_nixpkgs.url = "github:dguibert/nixpkgs/pu";
  };
}
