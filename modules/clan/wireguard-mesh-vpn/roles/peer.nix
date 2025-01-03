{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.clan.wireguard-mesh-vpn;
  clanDir = config.clan.core.settings.directory;
  varsDir = clanDir + "/vars/per-machine/";
  machineName = config.clan.core.settings.machine.name;

  # Instances might be empty, if the module is not used via the inventory
  #
  # Type: { ${instanceName} :: { roles :: Roles } }
  #   Roles :: { ${role_name} :: { machines :: [string] } }
  instances = config.clan.inventory.services.wireguard-mesh-vpn or { };

  peerNames = lib.foldlAttrs
    (
      acc: _instanceName: instanceConfig:
        acc
        ++ (
          builtins.filter (n: n != machineName) (instanceConfig.roles.peer.machines)
        )
    ) [ ]
    instances;

  generate_wg_keys = name: value: {
    name = "wg.${name}";
    value = {
      files = {
        key = { };
        "key.pub".secret = false;
        "key.pub".share = true;
        ipv4.secret = false;
      } // (builtins.listToAttrs (lib.map
        (n:
          { name = "${n}-ipv6"; value = { secret = false; }; })
        peerNames));
      prompts."ipv4" = { };
      runtimeInputs = [
        pkgs.wireguard-tools
      ];
      script = ''
        wg genkey > $out/key
        cat $out/key | wg pubkey | tr -d '\n' > $out/key.pub
      '' + (lib.concatMapStrings
        (n:
          # https://blog.fugoes.xyz/2018/02/03/Run-Babeld-over-Wireguard.html
          #printf "fd%x:%x:%x:%x::/64\n" "$(( $RANDOM/256 ))" "$RANDOM" "$RANDOM" "$RANDOM"
          ''
            printf "fe80::216:3eff:%x:%x/64" "$RANDOM" "$RANDOM" > $out/${n}-ipv6
          '')
        peerNames);
    };
  };

in
{
  options = {
    clan.wireguard-mesh-vpn = {
      peers = mkOption {
        default = { };
        #type = with types; loaOf (submodule peerOpts);
        example = { };
        description = ''
        '';
      };
    };
  };

  config = {
    clan.core.vars.generators = lib.mapAttrs' generate_wg_keys ({ "${machineName}" = { }; });
    environment.systemPackages = [ pkgs.wireguard-tools ];
    systemd.network.netdevs = listToAttrs (flip map peerNames
      (n:
        let
          peer = builtins.getAttr n cfg.peers;
        in
        nameValuePair "50-wg${n}" {
          netdevConfig.Kind = "wireguard";
          netdevConfig.Name = "wg${n}";
          netdevConfig.MTUBytes = "1300";

          wireguardConfig.PrivateKeyFile = config.clan.core.vars.generators."wg.${machineName}".files.key.path;
          wireguardConfig.ListenPort = peer.listenPort;

          wireguardPeers = [
            {
              PublicKey = builtins.readFile (varsDir + n + "/wg.${n}/key.pub/value");
              AllowedIPs = [
                "0.0.0.0/0"
                "::/0"
                # The Babel protocol uses IPv6 link-local unicast and multicast addresses
                "fe80::/64"
                "ff02::1:6/128"
              ];
              Endpoint = if (peer ? endpoint) then peer.endpoint else null;
              PersistentKeepalive = peer.persistentKeepalive or 0;
            }
          ];
        }));
    systemd.network.networks = listToAttrs (flip map peerNames
      (n: nameValuePair "wg${n}" {
        matchConfig.Name = "wg${n}";
        address = [
          ##peers."${machineName}".ipv4Address
          config.clan.core.vars.generators."wg.${machineName}".files.ipv4.value
          # Assign an IPv6 link local address on the tunnel so multicast works
          ##peers."${machineName}".ipv6Addresses.${n}
          config.clan.core.vars.generators."wg.${machineName}".files."${n}-ipv6".value
        ];
        DHCP = "no";
        #networkConfig = {
        #  #IPMasquerade = "ipv4";
        #  IPForward = true;
        #};
      }));

    services.babeld.enable = true;
    services.babeld.interfaceDefaults = {
      type = "tunnel";
      "split-horizon" = true;
    };
    # https://www.kepstin.ca/blog/babel-routing-over-wireguard-for-the-tubes/
    services.babeld.extraConfig = ''
      ${concatMapStrings (n: ''
        interface wg${n}
      '') peerNames}
      skip-kernel-setup true
      # Prefer using unicast messages over the tunnel
      default unicast true
      # mesh IPv4
      redistribute local ip 10.147.27.0/24 metric 128
      redistribute ip 10.147.27.0/24 ge 13 metric 128
      ## refuse anything else not explicitely allowed
      redistribute local deny
      redistribute deny
    '';
    systemd.services.babeld = {
      serviceConfig = {
        #IPAddressAllow = [ "fe80::/64" "ff00::/8" "::1/128" "127.0.0.0/8" "10.147.27.0/24" ];
        IPAddressAllow = [ "10.147.27.0/24" ];
        RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
      };
    };

    networking.firewall.allowedUDPPorts = [ 6696 ];
  };
}


