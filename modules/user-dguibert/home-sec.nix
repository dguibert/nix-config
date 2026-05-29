{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  home-secret =
    let
      home_sec = pkgs.sopsDecrypt_ ./_home-sec.nix "data";
      loaded = home_sec.success or true;
    in
    if loaded then
      (builtins.trace "loaded encrypted ./home-sec.nix (${toString loaded})" home_sec)
    else
      (builtins.trace "use dummy        ./home-sec.nix (${toString loaded})" ({ ... }: { }));

in
{
  flake-file.inputs = {
    sops-nix.url = "github:dguibert/sops-nix/pu"; # for dg/use-with-cross-system
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.aspects.dguibert-home-sec.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-home-sec
  ];
  flake.aspects.dguibert-home-sec.homeManager.imports = [
    home-secret
    inputs.sops-nix.homeManagerModules.sops
    (
      { ... }:
      {
        sops.age.sshKeyPaths = [ "/home/dguibert/.ssh/id_ed25519" ];
        sops.defaultSopsFile = ./secrets.yaml;

        sops.secrets.netrc = { };
        sops.secrets.pass-email1 = { };
        sops.secrets.pass-email2 = { };

        #home.file.".netrc".source = config.sops.secrets.netrc.path;
      }
    )
  ];
}
