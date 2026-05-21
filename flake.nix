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
    allfollow.url = "github:spikespaz/allfollow";
    base16.url = "github:SenchoPens/base16.nix";
    base16-shell = {
      url = "github:tinted-theming/tinted-shell";
      flake = false;
    };
    base16-vim = {
      url = "github:tinted-theming/base16-vim";
      flake = false;
    };
    clan-core.url = "git+https://git.clan.lol/clan/clan-core";
    deploy-rs.url = "github:dguibert/deploy-rs/pu";
    disko.url = "github:nix-community/disko";
    envfs.url = "github:Mic92/envfs";
    flake-aspects.url = "github:vic/flake-aspects";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    gitignore = {
      url = "github:hercules-ci/gitignore";
      flake = false;
    };
    home-manager.url = "github:dguibert/home-manager/pu";
    hyprland.url = "git+https://github.com/dguibert/Hyprland?ref=refs/heads/main&submodules=1";
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprsplit.url = "github:dguibert/hyprsplit";
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    microvm.url = "github:astro/microvm.nix";
    nix.url = "github:dguibert/nix/pu";
    nix-ld.url = "github:Mic92/nix-ld";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixpkgs.url = "github:dguibert/nixpkgs/pu";
    nur_packages.url = "github:dguibert/nur-packages?ref=master";
    nxsession.url = "github:dguibert/nxsession";
    sops-nix.url = "github:dguibert/sops-nix/pu";
    stylix.url = "github:danth/stylix";
    systems.url = "github:nix-systems/default-linux";
    terranix = {
      url = "github:mrVanDalo/terranix";
      flake = false;
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    tt-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };
}
