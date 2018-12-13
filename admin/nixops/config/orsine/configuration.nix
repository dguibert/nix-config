####{ config, nodes, pkgs, lib, ...}@attrs:
####with lib;
####rec {
####  imports = [
####    ./orsine/configuration.nix
####    ./common.nix
####  ] ++ (import ../services/service-list.nix) { attr = "orsine"; } attrs;
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

rec {

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    <config/common.nix>
    <config/users/dguibert>
    <modules/nix-conf.nix>
    <modules/yubikey-gpg.nix>
    <modules/distributed-build.nix>
    <modules/x11.nix>
  ];
  nixpkgs.localSystem.system = "x86_64-linux";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S12PNEAD231035B";
  boot.kernelParams = ["resume=/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S12PNEAD231035B-part2" ];
  boot.loader.grub.configurationLimit = 10;

  boot.kernelModules = [ "fuse" "kvm-intel" ];
  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" "tm-smapi" ];
  boot.kernelPackages = pkgs.linuxPackages_4_19;
  boot.extraModulePackages = [ pkgs.linuxPackages.perf config.boot.kernelPackages.tp_smapi ];
#  nixpkgs.config = {pkgs}: (import <config/nixpkgs/config.nix> { inherit pkgs; }) // {
#    allowUnfree = true;
#    packageOverrides.linuxPackages = boot.kernelPackages;
#  };
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true; # Linux v4.18.1 is not yet supported by zfsonlinux v0.7.9

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/cc74b0e1-c5fb-4bf2-870a-e23363cd7849";
      fsType = "xfs";
    };
  fileSystems."/tmp" = { device="tmpfs"; options= [ "defaults" "noatime" "mode=1777" "size=3G" ]; fsType="tmpfs"; neededForBoot=true; };

  swapDevices = [ { device = "/dev/sda2"; } ];

  nix.maxJobs = 2;

  hardware.trackpoint.enable = true;
  hardware.trackpoint.emulateWheel = true;

  #  autoInstall = ''
  # https://wiki.archlinux.org/index.php/ZFS#Root_on_ZFS
  #  zpool create -o feature@multi_vdev_crash_dump=disabled \
  #                  -o feature@large_dnode=disabled        \
  #                  -o feature@sha512=disabled             \
  #                  -o feature@skein=disabled              \
  #                  -o feature@edonr=disabled              \
  #		  -o feature@encryption=disabled         \
  #                  $POOL_NAME $VDEVS
  #  zfs create -o setuid=off -o devices=off -o sync=disabled -o mountpoint=/tmp <pool>/tmp
  #  systemctl mask tmp.mount
  #  zfs create <nameofzpool>/<nameofdataset>
  #  zfs set quota=20G <nameofzpool>/<nameofdataset>/<directory>
  #  # zfs create -V 8G -b $(getconf PAGESIZE) \
  #               -o logbias=throughput -o sync=always\
  #               -o primarycache=metadata \
  #               -o com.sun:auto-snapshot=false <pool>/swap
  # # mkswap -f /dev/zvol/<pool>/swap
  # # swapon /dev/zvol/<pool>/swap
  #  '';

  networking.hostId = "a8c00e01";

  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.interfaces = [ "wlp0s29f7u1" ];
  networking.wireless.driver = "nl80211,wext";
  networking.wireless.userControlled.enable = true;

  systemd.network.netdevs."40-bond0" = {
    netdevConfig.Name = "bond0";
    netdevConfig.Kind = "bond";
    bondConfig.Mode="active-backup";
    bondConfig.MIIMonitorSec="100s";
    bondConfig.PrimaryReselectPolicy="always";
  };
  systemd.network.networks."40-bond0" = {
    name = "bond0";
    DHCP = "both";
    networkConfig.BindCarrier = "enp0s25 wlp0s29f7u1";
  };
#  systemd.network.networks = listToAttrs (flip map [ "enp0s25" "wlp0s26f7u1" ] (bi:
#    nameValuePair "40-${bi}" {
#      DHCP = "none";
#      networkConfig.Bond = "bond0";
#      networkConfig.IPv6PrivacyExtensions = "kernel";
#    }));
  #systemd.network.networks."99-main".name = "!zt0 wlp2s0";
  systemd.network.networks."40-enp0s25" = {
    name = "enp0s25";
    DHCP = "none";
    networkConfig.Bond = "bond0";
    #networkConfig.PrimarySlave=true;
    networkConfig.IPv6PrivacyExtensions = "kernel";
  };
  systemd.network.networks."40-wlp0s29f7u1" = {
    name = "wlp0s29f7u1";
    DHCP = "none";
    networkConfig.Bond = "bond0";
    #networkConfig.ActiveSlave=false;
    networkConfig.IPv6PrivacyExtensions = "kernel";
  };
  #{networking.bonds.bond0.interfaces = [ "enp0s25" /*"wlp0s26f7u1"*/ ];
  #{boot.extraModprobeConfig=''
  #{  options bonding mode=active-backup miimon=100 primary=enp0s25
  #{'';

  hardware.bluetooth.enable = true;

  services.logind.extraConfig = "LidSwitchIgnoreInhibited=no";

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioLight.override {
      /*gconf = gnome3.gconf;*/
      x11Support = true;
      /*gconfSupport = true;*/
      bluetoothSupport = true;
    };
  };
  services.tlp.enable = true;

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; let
      myTexLive = texlive.combine {
        inherit (texlive) scheme-small beamer pgf algorithms cm-super;
      };
    in [
    vim htop lsof
    wget telnet
    bc
    git
    gnuplot graphviz imagemagick
    diffstat diffutils binutils zip unzip
    unrar cabextract cpio p7zip lzma which file
    acpitool iputils
    fuse sshfsFuse
    manpages gnupg tree
# lsof - shows open files/sockets, including network
    lsof
    vim ethtool
    wirelesstools wpa_supplicant_gui
    alsaPlugins pavucontrol

    nixops
    config.boot.kernelPackages.perf 
  ] ++ (with aspellDicts; [en fr]) ++ [
    rxvt_unicode
    pkgs.disnixos pkgs.wireguard-tools
  ];

  # for X11.nix
  services.xserver.resolutions = [{x=1440; y=900;}];
  services.xserver.videoDrivers = [ "intel" ];
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];

  programs.sysdig.enable = true;

  programs.bash.enableCompletion = true;
  environment.shellInit = ''
    export NIX_PATH=nixpkgs=https://github.com/dguibert/nixpkgs/archive/pu.tar.gz:nixos-config=$HOME/admin/nixops/$(hostname)/configuration.nix
  '';

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.startWhenNeeded = true;
  services.openssh.ports = [22322];
  services.openssh.passwordAuthentication = false;
  services.openssh.hostKeys = [
    { type = "rsa"; bits = 4096; path = "/etc/ssh/ssh_host_rsa_key"; }
    { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
  ];
  services.openssh.extraConfig = ''
    Ciphers chacha20-poly1305@openssh.com,aes256-cbc,aes256-gcm@openssh.com,aes256-ctr
    KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
    MACs umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
  '';
  # https://www.sweharris.org/post/2016-10-30-ssh-certs/
  # http://www.lorier.net/docs/ssh-ca
  # https://linux-audit.com/granting-temporary-access-to-servers-using-signed-ssh-keys/
  users.users.root.openssh.authorizedKeys.keys = [
    "cert-authority ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCT6I73vMHeTX7X990bcK+RKC8aqFYOLZz5uZhwy8jtx/xEEbKJFT/hggKADaBDNkJl/5141VUJ+HmMEUMu+OznK2gE8IfTNOP1zLXD6SjOxCa55MvnyIiXVMAr7R0uxZWy28IrmcmSx1LY5Mx8V13mjY3mp3LVemAy9im+vj6FymjQqgPMg6dHq+aQCeHpx22GWHYEq2ghqEsRpmIBBwwaVaEH8YIjcqZwDcp273SzBrgMEW44ndul5bvh85c71vjm7kblU/BxwBeLFMJFnXYTPxF2JjxhCSMlHBH9hqQjQ8vwaQev6XaJ5TpHgiT3nLAxCyBBgvnfwM7oq6bjHjuyToKFzUsFH6YVsK+/NjagZ5YKlV7vK0o2oF12GrQvwWwa6DUM+LdUNmSX4l4Xq8lB5YbJ5NK0pHRRdzCZL5kPuV+CkXRAHoUSj/pLUqkqGRL70NMtLIYmQbj/l7BZ4PQNP9zKLB4f5pk02A25DbPVfoW2DFL0DRfSF1L8ZDsAVhzUaRKSBZZ4wG231gvB6pCMTpeuvC9+Z/OmYkiXEOn34Qdjx8Bfi7XWKm/PnSgP7dM9Tcf3I0hvymvP6eZ8BjeriKHUE7b3s1aMQz9I4ctpbCNT5S16XMQZtdO0HZ+nn4Exhy0FHmdCwPXu/VBEBYcy7UpI4vyb1xiz13KVX/5/oQ== CA key for my accounts at home"
  ];
    #  boot.kernel.sysctl = {
    #    # enables syn flood protection
    #    "net.ipv4.tcp_syncookies" = "1";
    #
    #    # ignores source-routed packets
    #    "net.ipv4.conf.all.accept_source_route" = "0";
    #
    #    # ignores source-routed packets
    #    "net.ipv4.conf.default.accept_source_route" = "0";
    #
    #    # ignores ICMP redirects
    #    "net.ipv4.conf.all.accept_redirects" = "0";
    #
    #    # ignores ICMP redirects
    #    "net.ipv4.conf.default.accept_redirects" = "0";
    #
    #    # ignores ICMP redirects from non-GW hosts
    #    "net.ipv4.conf.all.secure_redirects" = "1";
    #
    #    # ignores ICMP redirects from non-GW hosts
    #    "net.ipv4.conf.default.secure_redirects" = "1";
    #
    #    # don't allow traffic between networks or act as a router
    #    "net.ipv4.ip_forward" = "0";
    #
    #    # don't allow traffic between networks or act as a router
    #    "net.ipv4.conf.all.send_redirects" = "0";
    #
    #    # don't allow traffic between networks or act as a router
    #    "net.ipv4.conf.default.send_redirects" = "0";
    #
    #    # reverse path filtering - IP spoofing protection
    #    "net.ipv4.conf.all.rp_filter" = "1";
    #
    #    # reverse path filtering - IP spoofing protection
    #    "net.ipv4.conf.default.rp_filter" = "1";
    #
    #    # ignores ICMP broadcasts to avoid participating in Smurf attacks
    #    "net.ipv4.icmp_echo_ignore_broadcasts" = "1";
    #
    #    # ignores bad ICMP errors
    #    "net.ipv4.icmp_ignore_bogus_error_responses" = "1";
    #
    #    # logs spoofed, source-routed, and redirect packets
    #    "net.ipv4.conf.all.log_martians" = "1";
    #
    #    # log spoofed, source-routed, and redirect packets
    #    "net.ipv4.conf.default.log_martians" = "1";
    #
    #    # implements RFC 1337 fix
    #    "net.ipv4.tcp_rfc1337" = "1";
    #  };


  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.147.27.123/24" ];
    listenPort = 51820;
    privateKeyFile = toString <secrets/orsine/wireguard_key>;
    peers = [
      { allowedIPs = [ "10.147.27.0/24" ];
        publicKey  = "wBBjx9LCPf4CQ07FKf6oR8S1+BoIBimu1amKbS8LWWo=";
        endpoint   = "83.155.85.77:500";
      }
      { allowedIPs = [ "10.147.27.198/32" ];
        publicKey  = "rbYanMKQBY/dteQYQsg807neESjgMP/oo+dkDsC5PWU=";
        endpoint   = "orsin.freeboxos.fr:51821";
	#persistentKeepalive = 25;
      }
      { allowedIPs = [ "10.147.27.128/32" ];
        publicKey  = "apJCCchRSbJnTH6misznz+re4RYTxfltROp4fbdtGzI=";
        endpoint   = "192.168.1.45:500";
      }
      { allowedIPs = [ "10.147.27.123/32" ];
        publicKey  = "Z8yyrih3/vINo6XlEi4dC5i3wJCKjmmJM9aBr4kfZ1k=";
        endpoint   = "orsin.freeboxos.fr:51820";
      }
    ];
  };
  networking.firewall.allowedUDPPorts = [ 9993 51820 ];

  services.wakeonlan.interfaces = [
    {
      interface = "enp0s25";
      method = "magicpacket";
      #method = "password";
      #password = "00:11:22:33:44:55";
    }
  ];

  # Virtualisation
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableHardening = false;

  services.udev.packages = [ pkgs.android-udev-rules ];
  services.udev.extraRules = with pkgs; ''
          # This files changes the mode of the Dynastream ANT UsbStick2 so all users can read and write to it.
          SUBSYSTEM=="usb", ATTR{idVendor}=="0fcf", ATTR{idProduct}=="1008", MODE="0666", SYMLINK+="ttyANT", ACTION=="add"
  '';

  #virtualisation.libvirtd.enable = true;
  networking.firewall.checkReversePath = false;

  # ChromeCast ports
  # iptables -I INPUT -p udp -m udp --dport 32768:61000 -j ACCEPT
  networking.firewall.allowedUDPPortRanges = [ { from=32768; to=61000; } ];

  # (evince:16653): dconf-WARNING **: failed to commit changes to dconf:
  # GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name
  # ca.desrt.dconf was not provided by any .service files
  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  ## /dev/disk/by-id/ata-WDC_WD10TMVV-11TK7S1_WD-WXL1E61NHVC1-part9
  ## /dev/disk/by-id/ata-WDC_WD10TMVV-11TK7S1_WD-WXL1E61PEJW5-part9
  ## /dev/disk/by-id/ata-WDC_WD10TMVV-11TK7S1_WD-WXL1E61NTXH5-part9
  ## 
  ##[Unit]
  ##After=dev-disk-by\x2did-wwn\x2d0x60014057ab42867d066fd393edb4abd6.device
  ##
  ##[Service]
  ##ExecStart=/usr/sbin/zpool import itank
  ##ExecStartPost=/usr/bin/logger "started ZFS pool itank"
  ##
  ##[Install]
  ##WantedBy=dev-disk-by\x2did-wwn\x2d0x60014057ab42867d066fd393edb4abd6.device
  systemd.services.zfs-import-backupwd = {
    description = "automatically import backupwd zpool";
    after = [
      "dev-disk-by\\x2did-ata\\x2dWDC_WD10TMVV\\x2d11TK7S1_WD\\x2dWXL1E61NHVC1\\x2dpart9.device"
      "dev-disk-by\\x2did-ata\\x2dWDC_WD10TMVV\\x2d11TK7S1_WD\\x2dWXL1E61PEJW5\\x2dpart9.device"
      "dev-disk-by\\x2did-ata\\x2dWDC_WD10TMVV\\x2d11TK7S1_WD\\x2dWXL1E61NTXH5\\x2dpart9.device"
    ];
    wantedBy = [
      "dev-disk-by\\x2did-ata\\x2dWDC_WD10TMVV\\x2d11TK7S1_WD\\x2dWXL1E61NHVC1\\x2dpart9.device"
      "dev-disk-by\\x2did-ata\\x2dWDC_WD10TMVV\\x2d11TK7S1_WD\\x2dWXL1E61PEJW5\\x2dpart9.device"
      "dev-disk-by\\x2did-ata\\x2dWDC_WD10TMVV\\x2d11TK7S1_WD\\x2dWXL1E61NTXH5\\x2dpart9.device"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.zfs}/sbin/zpool import backupwd";
      #ExecStartPost = "logger \"started ZFS pool backupwd\"";
    };
  };

  services.disnix.enable = true;
}
