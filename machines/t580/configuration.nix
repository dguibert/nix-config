{ config, pkgs, lib, ... }:
with lib;
rec {
  imports =
    [
      { nixpkgs.system = "x86_64-linux"; }
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ({ ... }: { services.udisks2.enable = true; })
      ../../modules/nixos/defaults
    ];
  disko.devices = import ./disk-config.nix {
    inherit lib;
  };


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 6;

  services.fwupd.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  networking.useNetworkd = lib.mkForce false;
  networking.useDHCP = false;
  systemd.network.enable = lib.mkForce true;
  networking.dhcpcd.enable = false;

  systemd.network.networks = {
    "40-wlan0" = {
      name = "wlan0";
      DHCP = "yes";
      linkConfig.MACAddress = "d2:b6:17:1d:b8:97";
      # make routing on this interface a dependency for network-online.target
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  programs.bash.enableCompletion = true;
  # List services that you want to enable:

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

  programs.light.enable = true;

  services.udev.extraRules = with pkgs; ''
    # This files changes the mode of the Dynastream ANT UsbStick2 so all users can read and write to it.
    SUBSYSTEM=="usb", ATTR{idVendor}=="0fcf", ATTR{idProduct}=="1008", MODE="0666", SYMLINK+="ttyANT", ACTION=="add"
  '';

}

