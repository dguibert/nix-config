{ inputs
, lib
, config
, pkgs
, ...
}:
let
  l = lib // builtins;
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

    # Ensure that all files are properly chowned
    # https://github.com/Misterio77/nix-config/blob/61aa0ab5e26c528eb6be98dee1a8b9061003bf2e/hosts/common/global/optin-persistence.nix#L29-L38
    systemd.services."persist-home-create-root-paths" =
      let
        persistentHomesRoot = "/persist";

        listOfCommands = l.mapAttrsToList
          (_: user:
            let
              userHome = l.escapeShellArg (persistentHomesRoot + user.home);

            in
            ''
              if [[ ! -d ${userHome} ]]; then
                  echo "Persistent home root folder '${userHome}' not found, creating..."
                  mkdir -p --mode=${user.homeMode} ${userHome}
              fi
              chown ${user.name}:${user.group} ${userHome}
            ''
          )
          (l.filterAttrs (_: user: user.createHome == true) config.users.users);

        stringOfCommands = l.concatLines listOfCommands;
      in
      {
        script = stringOfCommands;
        unitConfig = {
          Description = "Ensure users' home folders exist in the persistent filesystem";
          PartOf = [ "local-fs.target" ];
          # The folder creation should happen after the persistent home path is mounted.
          After = [ "persist-home.mount" ];
        };

        serviceConfig = {
          Type = "oneshot";
          StandardOutput = "journal";
          StandardError = "journal";
        };

        # [Install]
        wantedBy = [ "local-fs.target" ];

      };

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
