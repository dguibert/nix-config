{ inputs, ... }:
{
  flake-file.description = "Configurations of my systems";

  flake-file.nixConfig.extra-experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];

  ##        deploy.nodes = builtins.foldl' inputs.nur_packages.lib.recursiveUpdate { } [
  ##          (inputs.nur_packages.lib.mapAttrs
  ##            (
  ##              host: nixosConfig:
  ##              let
  ##                system = nixosConfig.config.nixpkgs.localSystem.system;
  ##              in
  ##              {
  ##                hostname = "${nixosConfig.config.networking.hostName}";
  ##                sshOpts = [
  ##                  "-o"
  ##                  "ControlMaster=no"
  ##                ]; # https://github.com/serokell/deploy-rs/issues/106
  ##                profilesOrder = [
  ##                  "system"
  ##                  "dguibert"
  ##                ];
  ##                profiles.system.path = self.legacyPackages.${system}.deploy-rs.lib.activate.nixos nixosConfig;
  ##                profiles.system.user = "root";
  ##                # Fast connection to the node. If this is true, copy the whole closure instead of letting the node substitute.
  ##                fastConnection = true;
  ##
  ##                # If the previous profile should be re-activated if activation fails.
  ##                autoRollback = true;
  ##
  ##                # See the earlier section about Magic Rollback for more information.
  ##                # This defaults to `true`
  ##                magicRollback = false;
  ##              }
  ##            )
  ##            (
  ##              builtins.removeAttrs self.nixosConfigurations [
  ##                "iso"
  ##                "iso-aarch64"
  ##              ]
  ##            )
  ##          )
  ##          # root profiles
  ##          (inputs.nur_packages.lib.mapAttrs
  ##            (
  ##              host: homeConfig:
  ##              let
  ##                system = self.nixosConfigurations.${host}.config.nixpkgs.localSystem.system;
  ##              in
  ##              {
  ##                #profiles.root.path = inputs.deploy-rs.lib.aarch64-linux.activate.custom
  ##                profiles.dguibert.path =
  ##                  self.legacyPackages.${system}.deploy-rs.lib.activate.custom homeConfig.activationPackage
  ##                    "./activate";
  ##                profiles.dguibert.user = "root";
  ##              }
  ##            )
  ##            {
  ##              rpi02 = self.homeConfigurations."root@rpi02";
  ##              rpi31 = self.homeConfigurations."root@rpi31";
  ##              rpi41 = self.homeConfigurations."root@rpi41";
  ##              titan = self.homeConfigurations."root@titan";
  ##              t580 = self.homeConfigurations."root@t580";
  ##            }
  ##          )
  ##          (
  ##            let
  ##            in
  ##            {
  ##              spartan = {
  ##                hostname = "spartan";
  ##                sshOpts = [
  ##                  "-o"
  ##                  "ControlMaster=no"
  ##                ]; # https://github.com/serokell/deploy-rs/issues/106
  ##                fastConnection = true;
  ##                autoRollback = false;
  ##                magicRollback = false;
  ##
  ##                profiles.bguibertd = genProfile "bguibertd" "bguibertd@spartan" "hm";
  ##                profiles.bguibertd-x86_64 = genProfile "bguibertd" "bguibertd@spartan-x86_64" "hm-x86_64";
  ##                profiles.bguibertd-aarch64 = genProfile "bguibertd" "bguibertd@spartan-aarch64" "hm-aarch64";
  ##              };
  ##
  ##              param = {
  ##                hostname = "param";
  ##                fastConnection = true;
  ##                autoRollback = false;
  ##                magicRollback = false;
  ##
  ##                profiles.user = genProfile "gdavid" "gdavid@param" "hm";
  ##              };
  ##            }
  ##          )
  ##
  ##          ({ })
  ##        ];
  ##
  ##      };
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  ##      perSystem =
  ##        {
  ##          config,
  ##          self',
  ##          inputs',
  ##          pkgs,
  ##          system,
  ##          ...
  ##        }:
  ##        {
  ##          # This is highly advised, and will prevent many possible mistakes
  ##          checks = (self.legacyPackages.${system}.deploy-rs.lib.deployChecks inputs.self.deploy);
  ##
  ##        };
  ##    };

}
