# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  #  imports =
  #    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  #    ];

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call pkgs.linuxPackages.perf ];
  networking.hostId = "8425e349"; # - ZFS requires networking.hostId to be set
  boot.kernelParams = [
    #"acpi_backlight=video"
    "resume=LABEL=nvme-swap"
    # https://github.com/NixOS/nixpkgs/issues/36392
    "i915.enable_fbc=1"
    "i915.enable_guc=2"
    "i915.modeset=1"
    "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
  ];

  #fileSystems."/tmp".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  # https://grahamc.com/blog/erase-your-darlings
  boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) (lib.mkAfter ''
    zpool import rpool_rt580
    #zfs rollback -r rpool_rt580/local/root@blank
    zfs rollback -r rpool_rt580/local/empty-root@blank
  '');
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      #"zfs-import-rpool_rt580.service"
      "zfs-import.target"
    ];
    before = [
      "sysroot.mount"
    ];
    path = with pkgs; [
      zfs
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool_rt580/local/empty-root@blank && echo "rollback complete"
    '';
  };
  environment.persistence."/persist" = {
    hideMounts = true;
    enableDebugging = true;
    directories = [
      "/var/log"
      "/var/lib/jellyfin"
      "/var/lib/nixos"
      "/var/lib/bluetooth"
      "/var/lib/iwd"
      #"/var/lib/step-ca"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  # https://lists.ubuntu.com/archives/kernel-team/2020-November/114986.html
  #boot.kernelPackages = pkgs.linuxPackages_testing;
  # *** ZFS Version: zfs-2.0.4-1
  # *** Compatible Kernels: 3.10 - 5.11
  #boot.zfs.package = pkgs.zfs_unstable;
  boot.zfs.allowHibernation = true;
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "monthly";
  services.zfs.trim.enable = true;
  # https://grahamc.com/blog/nixos-on-zfs
  # rpool_rt580/
  # ├── local
  # │   ├── nix
  # │   └── root
  # └── safe
  #     └── home
  #         ├── dguibert
  #         └── root
  services.sanoid = {
    enable = true;
    interval = "*:00,15,30,45"; #every 15minutes
    templates.user = {
      frequently = 8;
      hourly = 24;
      daily = 7;
      monthly = 3;
      yearly = 0;

      autosnap = true;
    };
    templates.root = {
      frequently = 8;
      hourly = 4;
      daily = 2;
      monthly = 2;
      yearly = 0;

      autosnap = true;
    };
    datasets."rpool_rt580/safe".use_template = [ "user" ];
    datasets."rpool_rt580/safe".recursive = true;
    datasets."rpool_rt580/local/root".use_template = [ "root" ];
    datasets."rpool_rt580/local/root".recursive = true;
    datasets."rpool_rt580/local/empty-root".use_template = [ "root" ];
    datasets."rpool_rt580/local/empty-root".recursive = true;

    extraArgs = [ "--verbose" ];
  };

  nix.settings.max-jobs = lib.mkDefault 8;

  services.xserver.libinput.enable = lib.mkDefault true;
  hardware.trackpoint.enable = lib.mkDefault true;
  hardware.trackpoint.emulateWheel = lib.mkDefault config.hardware.trackpoint.enable;
  hardware.bluetooth.enable = true;

  # Disable governor set in hardware-configuration.nix,
  # required when services.tlp.enable is true:
  powerManagement.cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);

  services.tlp.enable = lib.mkDefault true;
  services.tlp.settings = {
    #https://linrunner.de/tlp/support/optimizing.html

    TLP_DEFAULT_MODE = "BAT";
    # Extend battery runtime
    ## Change CPU energy/performance policy to balance_power (default is balance_performance):
    #CPU_ENERGY_PERF_POLICY_ON_AC="balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";

    ## Change CPU energy/performance policy to power (default is balance_power):
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

    ## Disable turbo boost:
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;

    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    # Reduce power consumption / fan noise on AC power
    ## Enable runtime power management:
    RUNTIME_PM_ON_AC = "auto";
    RUNTIME_PM_ON_BAT = "auto";

  };

  services.udev.extraRules = ''
    # Suspend the system when battery level drops to 5% or lower
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
  '';

}
