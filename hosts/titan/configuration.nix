# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, utils, inputs, ... }:

with utils;
let
  migrate = fs1: fs2: {
    device = "none";
    fsType = "migratefs";
    #neededForBoot = true;
    options =
      [
        # Filesystem options
        "allow_other,lowerdir=${fs1},upperdir=${fs2}"
        #"nofail"
        "X-mount.mkdir"
        "x-systemd.requires-mounts-for=${fs1}"
        "x-systemd.requires-mounts-for=${fs2}"
      ];
  };
in
rec {
  imports = [
    ({ ... }: { services.udisks2.enable = true; })
    #../../modules/wayland-nvidia.nix
    inputs.microvm.nixosModules.host
  ];
  disko.devices = import ./disk-config.nix {
    inherit lib;
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "isci" "usbhid" "usb_storage" "sd_mod" "nvme" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = ''
    # 24G
    options zfs zfs_arc_max=25769803776
    options zfs zfs_vdev_scheduler="none"
    # use the prefetch method
    options zfs zfs_prefetch_disable=0

    options zfs zfs_dirty_data_max_percent=40
    options zfs zfs_txg_timeout=15
  '';

  # https://grahamc.com/blog/erase-your-darlings
  boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) (lib.mkAfter ''
    zpool import rpool_vanif0
    zfs rollback -r rpool_vanif0/local/root@blank
    zfs rollback -r rpool_vanif0/local/home/dguibert@blank && echo "rollback complete"
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
      zfs rollback -r rpool_vanif0/local/root@blank && echo "rollback complete"
      zfs rollback -r rpool_vanif0/local/home/dguibert@blank && echo "rollback complete"
    '';
  };


  fileSystems."/tmp".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/persist/home/dguibert".neededForBoot = true;
  fileSystems."/persist/home/dguibert/Videos".neededForBoot = true;
  fileSystems."/persist/home/dguibert/Maildir/.notmuch".neededForBoot = true;
  # https://github.com/nix-community/impermanence
  environment.persistence."/persist" = {
    hideMounts = true;
    enableDebugging = true;
    directories = [
      "/var/log"
      "/var/lib/jellyfin"
      "/var/lib/nixos"
      "/var/lib/bluetooth"
      #"/var/lib/step-ca"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  #fileSystems."/tmp" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "defaults" "noatime" "mode=1777" "size=140G" ]; neededForBoot = true; };
  # to build robotnix more thant 100G are needed
  # git/... fails with normalization/utf8only of zfs
  #fileSystems."/tmp"                                = { device="rpool_vanif0/local/tmp"; fsType="zfs"; options= [ "defaults" "noatime" "mode=1777" ]; neededForBoot=true; };

  # Maintenance target for later
  # https://www.immae.eu/blog/tag/nixos.html
  systemd.targets.maintenance = {
    description = "Maintenance target with only sshd";
    after = [ "network-online.target" "network-setup.service" "sshd.service" ];
    requires = [ "network-online.target" "network-setup.service" "sshd.service" ];
    unitConfig = {
      AllowIsolate = "yes";
    };
  };
  #systemctl isolate maintenance.target
  #systemctl stop systemd-journald systemd-journald.socket systemd-journald-dev-log.socket systemd-journald-audit.socket
  #rsync -aHAXS --delete --one-file-system / /mnt/

  boot.kernelParams = [
    "console=tty0"
    "console=ttyS1,115200n8"
    "loglevel=6"
    #"resume=/dev/disk/by-id/nvme-CT1000P1SSD8_2014E299CA2B-part1"
    "resume=/dev/disk/by-id/nvme-CT1000P2SSD8_2143E5DDD965-part2"
    #"add_efi_memmap"
    #"acpi_osi="
    # pmd_set_huge: Cannot satisfy [mem 0xf8000000-0xf8200000] with a huge-page mapping due to MTRR override
    #https://lwn.net/Articles/635357/
    "nohugeiomap"
    "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    #"nvidia.NVreg_PreserveVideoMemoryAllocations=1"

  ];
  boot.zfs.devNodes = "/dev/disk/by-id";

  nix.settings.max-jobs = lib.mkDefault 8;
  nix.settings.build-cores = lib.mkDefault 24;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi1";
  #boot.loader.grub.efiSupport = true;
  #boot.loader.grub.device = "nodev";
  console.earlySetup = true;

  networking.hostId = "8425e349";
  networking.hostName = "titan";

  ##qemu-user.aarch64 = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];
  ##boot.binfmt.registrations."aarch64-linux".preserveArgvZero=true;
  boot.binfmt.registrations."aarch64-linux".fixBinary = true;
  ##boot.binfmt.registrations."armv7l-linux".preserveArgvZero=true;
  boot.binfmt.registrations."armv7l-linux".fixBinary = true;

  services.openssh.enable = true;

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ pkgs.linuxPackages.perf ];
  # *** ZFS Version: zfs-2.0.4-1
  # *** Compatible Kernels: 3.10 - 5.11
  #boot.zfs.package = pkgs.zfs_unstable;
  boot.zfs.allowHibernation = true;
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "monthly";
  services.zfs.trim.enable = true;
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

  networking.dhcpcd.enable = false;
  networking.useNetworkd = lib.mkForce false;
  networking.useDHCP = false;
  systemd.network.enable = lib.mkForce true;

  systemd.network.netdevs."40-bond0" = {
    netdevConfig.Name = "bond0";
    netdevConfig.Kind = "bond";
    #[Bond]
    #Mode=active-backup
    #PrimaryReselectPolicy=always
    #PrimarySlave=enp3s0
    #TransmitHashPolicy=layer3+4
    #MIIMonitorSec=1s
    #LACPTransmitRate=fast

    bondConfig.Mode = "802.3ad";
    #bondConfig.PrimarySlave="eno1";
  };
  systemd.network.config.dhcpV4Config.DUIDType = "vendor";
  systemd.network.networks."40-bond0" = {
    name = "bond0";
    DHCP = "yes";
    networkConfig.BindCarrier = "eno1 eno2";
    # make routing on this interface a dependency for network-online.target
    linkConfig.RequiredForOnline = "routable";
    linkConfig.MACAddress = "1A:8E:26:C3:83:BB";
  };
  systemd.network.networks."40-eno1" = {
    name = "eno1";
    DHCP = "no";
    networkConfig.Bond = "bond0";
    networkConfig.IPv6PrivacyExtensions = "kernel";
    linkConfig.MACAddress = "1A:8E:26:C3:83:BB";
    linkConfig.RequiredForOnline = "no";
  };
  systemd.network.networks."40-eno2" = {
    name = "eno2";
    DHCP = "no";
    networkConfig.Bond = "bond0";
    networkConfig.IPv6PrivacyExtensions = "kernel";
    linkConfig.MACAddress = "1A:8E:26:C3:83:BB";
    linkConfig.RequiredForOnline = "no";
  };

  #specialisation.nvidia = {
  #  inheritParentConfig = true;
  #  configuration = {
  # https://nixos.wiki/wiki/Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    powerManagement.enable = true;
    open = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    #package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    forceFullCompositionPipeline = true;
  };
  #  };
  #};
  #nixpkgs.config.xorg.abiCompat = "1.18";
  hardware.bluetooth.enable = true;
  services.mpris-proxy.enable = true;
  hardware.enableAllFirmware = true;

  # https://nixos.org/nixos/manual/index.html#sec-container-networking
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-+" ];
  networking.nat.externalInterface = "bond0";

  # https://wiki.archlinux.org/index.php/Improving_performance#Input/output_schedulers
  services.udev.extraRules = with pkgs; ''
    # set scheduler for NVMe
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    # set scheduler for SSD and eMMC
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # set scheduler for rotating disks
    # udevadm info -a -n /dev/sda | grep queue
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="none"

    # set scheduler for ZFS member
    # udevadm info --query=all --name=/dev/sda
    # https://github.com/openzfs/zfs/pull/9609
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{ID_FS_TYPE}=="zfs_member", ATTR{queue/scheduler}="none"
    ACTION=="add|change", SUBSYSTEM=="block", ATTRS{ID_SERIAL_SHORT}=="WGS3EP4M", ATTR{queue/scheduler}="none"
    ACTION=="add|change", SUBSYSTEM=="block", ATTRS{ID_SERIAL_SHORT}=="WGS20WK1", ATTR{queue/scheduler}="none"
    ACTION=="add|change", SUBSYSTEM=="block", ATTRS{ID_SERIAL_SHORT}=="WGS25XFD", ATTR{queue/scheduler}="none"
    ACTION=="add|change", SUBSYSTEM=="block", ATTRS{ID_SERIAL_SHORT}=="WGS38E3P", ATTR{queue/scheduler}="none"
    ACTION=="add|change", SUBSYSTEM=="block", ATTRS{ID_SERIAL_SHORT}=="WGS20WGY", ATTR{queue/scheduler}="none"
    ACTION=="add|change", SUBSYSTEM=="block", ATTRS{ID_SERIAL_SHORT}=="WGS1T415", ATTR{queue/scheduler}="none"

    # https://bugzilla.kernel.org/show_bug.cgi?id=203973#c68
    ACTION=="add", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", \
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1949", ATTRS{idProduct}=="0324", \
    ATTR{events_poll_msecs}="800"
  '';

  services.sanoid = {
    enable = true;
    interval = "*:00,15,30,45"; #every 15minutes
    templates.prod = {
      frequently = 8;
      hourly = 24;
      daily = 7;
      monthly = 3;
      yearly = 0;

      autosnap = true;
    };
    templates.media = {
      hourly = 4;
      daily = 2;
      monthly = 2;
      yearly = 0;

      autosnap = true;
    };
    datasets."rpool_vanif0/local/root".use_template = [ "prod" ];
    datasets."rpool_vanif0/safe".use_template = [ "prod" ];
    datasets."rpool_vanif0/safe".recursive = true;
    datasets."rpool_vanif0/safe/home/dguibert/Videos".use_template = [ "media" ];
    datasets."rpool_vanif0/safe/home/dguibert/Videos".recursive = true;

    templates.backup = {
      autoprune = true;
      ### don't take new snapshots - snapshots on backup
      ### datasets are replicated in from source, not
      ### generated locally
      autosnap = false;

      frequently = 0;
      hourly = 36;
      daily = 30;
      monthly = 12;
    };
    datasets."st4000dm004-1/backup/rpool_vanif0".use_template = [ "backup" ];
    datasets."st4000dm004-1/backup/rpool_vanif0".recursive = true;

    extraArgs = [ "--verbose" ];
  };

  boot.zfs.extraPools = [ "st4000dm004-1" ];

  services.syncoid = {
    enable = true;
    #sshKey = "/root/.ssh/id_ecdsa";
    commonArgs = [ "--no-sync-snap" "--debug" "--quiet" /*"--create-bookmark"*/ ];
    #commands."pool/test".target = "root@target:pool/test";
    commands."rpool_vanif0/local/root".target = "st4000dm004-1/backup/rpool_vanif0/local/root";
    commands."rpool_vanif0/safe".target = "st4000dm004-1/backup/rpool_vanif0/safe";
    commands."rpool_vanif0/safe".recursive = true;
  };

}
