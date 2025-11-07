# https://nixos.org/nix-dev/2015-September/018255.html
{
  _class = "clan.service";
  manifest.name = "distributed-build";

  roles.server = {
    perInstance =
      {
        instanceName,
        settings,
        machine,
        roles,
        ...
      }:
      {
        nixosModule =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            clan.core.vars.generators.distributed-build = {
              files.ssh_ed25519 = { };
              files."ssh_ed25519.pub" = {
                deploy = false;
                secret = false;
              };
              script = ''ssh-keygen -t ed25519 -N " " -C " " -f $out/ssh_ed25519'';
              runtimeInputs = [ pkgs.openssh ];
            };

            users.extraUsers.nixBuild = {
              name = "nixBuild";
              useDefaultShell = true;
              openssh.authorizedKeys.keys = [
                config.clan.core.vars.generators."distributed-build".files."ssh_ed25519.pub".value
              ];
              isSystemUser = true;
            };
            users.users.nixBuild.group = "nixBuild";
            users.groups.nixBuild = { };

            nix.settings = {
              trusted-users = [
                "nixBuild"
                "dguibert"
              ];
            };

            #nix.settings.binary-cache-public-keys = [ "titan:dkOH0pvwo9CQMDs/H/Rs4HYEePVmwPf0/uSQi9ZmjxE=" ];
            nix.settings.trusted-binary-caches = [ "ssh-ng://titan?trusted=1" ];
          };
      };
  };

  roles.client = {
    perInstance =
      {
        instanceName,
        settings,
        machine,
        roles,
        lib,
        ...
      }:
      let
        allServers = lib.attrNames roles.server.machines;
      in
      {
        nixosModule =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            # on the client machine
            programs.ssh.extraConfig = ''
              Host rpi31
                HostName 192.168.1.13
                Port 22322
              Host rpi41
                HostName 192.168.1.14
                Port 22322
            '';
            # 20181219 titan is now able to build aarch64 (binfmt and qemu-user)
            nix.distributedBuilds = true;
            nix.buildMachines = map (
              n:
              (lib.mkIf (config.networking.hostName != n) {
                hostName = n;
                maxJobs = 1;
                #speedFactor = 2;
                sshKey = builtins.readFile (
                  config.clan.core.settings.directory
                  + "/vars/per-machine/${n}/distributed-build/ssh_ed25519.pub/value"
                );
                sshUser = "nixBuild";
                system = "aarch64-linux"; # FIXME assuming here that all are aarch64-linux
                supportedFeatures = [ "big-parallel" ];
              })
            ) allServers;

            #nix.settings.binary-cache-public-keys = [ "titan:dkOH0pvwo9CQMDs/H/Rs4HYEePVmwPf0/uSQi9ZmjxE=" ];
            nix.settings.trusted-binary-caches = [ "ssh-ng://titan?trusted=1" ];
          };
      };
  };
}
