{ config, pkgs, lib, ... }:
with lib;
rec {
  imports =
    [
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

  networking.hostName = "t580"; # Define your hostname.
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    General.AddressRandomization = "network";
    IPv6.Enabled = true;
    Settings.AutoConnect = true;
  };
  #systemd.tmpfiles.rules = [
  #  # "C /var/lib/iwd/network1.psk 0400 root root - /run/secrets/iwd_network_network1.psk"
  #  "C /var/lib/iwd/network1.psk 0600 root root - ${n1}"
  #  "C /var/lib/iwd/home.psk 0600 root root - ${config.sops.secrets."iwd_home.psk".path}"
  #];
  #networking.supplicant.wlp4s0 = {
  #  configFile.path = "/persist/etc/wpa_supplicant.conf";
  #  userControlled.group = "network";
  #  extraConf = ''
  #    ap_scan=1
  #    p2p_disabled=1
  #  '';
  #  extraCmdArgs = "-u";
  #};

  sops.defaultSopsFile = ./secrets/secrets.yaml;

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 22 ];
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # sudo /run/current-system/fine-tune/child-1/bin/switch-to-configuration test
  #- The option definition `nesting.clone' in `flake.nix' no longer has any effect; please remove it.
  #specialisation.«name» = { inheritParentConfig = true; configuration = { ... }; }
  #specialisation.work = { inheritParentConfig = true; configuration = {
  #    boot.loader.grub.configurationName = "Work";
  #    networking.proxy.default = "http://localhost:3128";
  #    networking.proxy.noProxy = "127.0.0.1,localhost,10.*,192.168.*";
  #    services.cntlm.enable = true;
  #    services.cntlm.username = "a629925";
  #    services.cntlm.domain = "ww930";
  #    services.cntlm.netbios_hostname = "fr-57nvj72";
  #    services.cntlm.proxy = [
  #      "10.89.0.72:84"
  #      #"proxy-emea.my-it-solutions.net:84"
  #      #"10.92.32.21:84"
  #      #"proxy-americas.my-it-solutions.net:84"
  #    ];
  #    services.cntlm.extraConfig = ''
  #      NoProxy localhost, 127.0.0.*, 10.*, 192.168.*
  #    '';

  #    users.users.cntlm.group = "cntlm";
  #    users.groups.cntlm = {};

  #  };
  #};

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

