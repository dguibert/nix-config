{
  description = "Configurations of my systems";

  inputs.upstream_nixpkgs.url = "git+file:///home/dguibert/code/nixpkgs";
  inputs.nur_packages.url = "git+file:///home/dguibert/code/nur-packages";
  inputs.nur_packages.inputs.nixpkgs.follows = "upstream_nixpkgs";
  inputs.nixpkgs_with_stdenv.url = "path:../nixpkgs";
  inputs.nixpkgs_with_stdenv.inputs.nixpkgs.follows = "nur_packages";

  inputs.nxsession.url = "github:dguibert/nxsession";
  inputs.nxsession.inputs.nixpkgs.follows = "nur_packages/nixpkgs";
  inputs.nxsession.inputs.flake-utils.follows = "nur_packages/flake-utils";

  # For accessing `deploy-rs`'s utility Nix functions
  inputs.deploy-rs.url = "github:dguibert/deploy-rs/pu";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nur_packages/nixpkgs";

  #inputs.hyprland.url = "github:hyprwm/Hyprland";
  #inputs.hyprland.url = "git+https://github.com/dguibert/Hyprland?submodules=1";
  inputs.hyprland.url = "git+file:///home/dguibert/code/Hyprland?&submodules=1";
  inputs.hyprland.inputs.nixpkgs.follows = "nur_packages";
  inputs.split-monitor-workspaces.url = "git+file:///home/dguibert/code/split-monitor-workspaces";
  inputs.split-monitor-workspaces.inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended

  inputs.hyprland-contrib = {
    url = "github:hyprwm/contrib";
    inputs.nixpkgs.follows = "nur_packages";
  };

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { ... }: {};
}
