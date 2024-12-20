{ config, lib, pkgs, inputs, self', ... }: {
  imports = [
    { nixpkgs.system = "x86_64-linux"; }
    ../../modules/nixos/defaults
    inputs.nix-ld.nixosModules.nix-ld

    # The module in this repository defines a new module under (programs.nix-ld.dev) instead of (programs.nix-ld)
    # to not collide with the nixpkgs version.
    { programs.nix-ld.dev.enable = true; }
    { environment.stub-ld.enable = false; } # conflict with nix-ld

    inputs.envfs.nixosModules.envfs
    #{ home-manager.users.dguibert = { imports = self'.modules.homes."dguibert@titan"; }; }
    #{users.dguibert.with-home-manager = true;}
  ];
  environment.systemPackages = [ pkgs.ipmitool pkgs.ntfs3g ];

  networking.firewall.checkReversePath = false;
}
