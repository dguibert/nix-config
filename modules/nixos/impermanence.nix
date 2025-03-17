{ inputs
, lib
, config
, pkgs
, ...
}:
let
  cfg = config.my.persistence;
  cfgHm = user: config.home-manager.users.${user}.my.persistence;
  hmUsers = builtins.attrNames config.home-manager.users;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options = {
    my.persistence = {
      enable = (lib.mkEnableOption "Enable impermanence config") // { default = false; };
      rollbackCommands = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    # https://grahamc.com/blog/erase-your-darlings
    boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) (lib.mkAfter ''
      zpool import -a
      ${cfg.rollbackCommands}
    '');
    boot.initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      after = [
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
      script = cfg.rollbackCommands;
    };
    boot.initrd.systemd.tmpfiles.settings.preservation."/sysroot/persist/etc/machine-id".f = {
      user = "root";
      group = "root";
      mode = ":0644";
      argument = "uninitialized\\n";
    };

    systemd.services.systemd-machine-id-commit = {
      unitConfig.ConditionPathIsMountPoint = [
        ""
        "/persist/etc/machine-id"
      ];
      serviceConfig.ExecStart = [
        ""
        "systemd-machine-id-setup --commit --root /persist"
      ];
    };

    # Ensure that all files are properly chowned
    # https://github.com/Misterio77/nix-config/blob/61aa0ab5e26c528eb6be98dee1a8b9061003bf2e/hosts/common/global/optin-persistence.nix#L29-L38
    system.activationScripts.persistent-dirs.text =
      let
        mkHomePersist =
          user:
          lib.optionalString user.createHome ''
            mkdir -p /persist/${user.home}
            chown ${user.name}:${user.group} /persist/${user.home}
            chmod ${user.homeMode} /persist/${user.home}
          '';
        users = lib.attrValues config.users.users;
      in
      lib.concatLines (map mkHomePersist users);

    fileSystems."/persist".neededForBoot = true;
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
        # Systemd requires /usr dir to be populated
        # See: https://github.com/nix-community/impermanence/issues/253
        "/usr/systemd-placeholder"
      ] ++ cfg.directories;
      files = [ "/etc/machine-id" ] ++ cfg.files;

      users = builtins.listToAttrs (
        lib.forEach hmUsers (user: {
          name = user;
          value = cfgHm user;
        })
      );
    };

    security.sudo.extraConfig = ''
      Defaults        lecture=never
    '';
  };
}
