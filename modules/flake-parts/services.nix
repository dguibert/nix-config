{ config, inputs, withSystem, self, ... }:
let
  # role-robotnix-ota-server
  role-robotnix-ota-server = [
    ../nixos/role-robotnix-ota.nix
    ({ config, lib, pkgs, inputs, ... }: {
      role.robotnix-ota-server.enable = true;
      role.robotnix-ota-server.openFirewall = true;
    })
  ];
  # platypush
  platypush = [
    ({ config, lib, pkgs, inputs, ... }: {
      services.redis.servers."".enable = true;
    })
  ];

  # zigbee
  zigbee = [
    ({ config, lib, pkgs, inputs, ... }: {
      role.zigbee.enable = true;
    })
  ];

  microvm = [
    inputs.microvm.nixosModules.host
    ({ config, lib, pkgs, inputs, ... }: {
      role.microvm.enable = true;
    })
  ];

  waydroid = [
    ({ config, lib, pkgs, inputs, ... }: {
      virtualisation.waydroid.enable = true;
    })
  ];

in
{
  modules.hosts.rpi41 = [ ]
    ++ zigbee
    ++ [
    ({ config, lib, pkgs, inputs, ... }: {
      hardware.graphics.enable32Bit = lib.mkForce false; # Option driSupport32Bit only makes sense on a 64-bit system.
    })
  ]
  ;
}
