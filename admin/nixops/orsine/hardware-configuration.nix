# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" "tm-smapi" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/cc74b0e1-c5fb-4bf2-870a-e23363cd7849";
      fsType = "xfs";
    };

  swapDevices = [ { device = "/dev/sda2"; } ];

  nix.maxJobs = 2;
}