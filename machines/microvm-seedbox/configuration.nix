{
  lib,
  config,
  pkgsForSystem,
  inputs,
  ...
}:
{
  imports = [
    { nixpkgs.system = "x86_64-linux"; }
    # Include the microvm module
    inputs.microvm.nixosModules.microvm
    ../../modules/nixos/defaults
  ];
  nix.optimise.automatic = lib.mkForce false;
  nix.settings.auto-optimise-store = lib.mkForce false;
  distributed-build-conf.enable = lib.mkForce false;

  microvm = {
    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];
    writableStoreOverlay = "/nix/.rw-store";
    # volumes = [ {
    #   image = "nix-store-overlay.img";
    #   mountPoint = config.microvm.writableStoreOverlay;
    #   size = 2048;
    # } ];
    interfaces = [
      {
        type = "tap";
        id = "vm-a1";
        mac = "02:00:00:01:01:01";
      }
    ];
    #forwardPorts = [{
    #  host.port = 2222;
    #  guest.port = 22;
    #}];
  };
  networking.useNetworkd = true;
  users.users.root.password = "";
  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKcj6Ig0DKYKNgeSlYaDtizs4mNN0hd23bFX1XaI8bzk dguibert@titan"
  ];
}
