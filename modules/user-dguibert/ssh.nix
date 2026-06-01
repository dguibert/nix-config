{ config, ... }:
{
  flake.aspects.dguibert-ssh.nixos.home-manager.users.dguibert.imports = [
    config.flake.modules.homeManager.dguibert-ssh
  ];
  flake.aspects.dguibert-ssh.homeManager =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      # ssh -F ssh_config $host -o PubkeyAuthentication=yes -Nf
      # ssh -F ssh_config $host -O check
      # ssh -F ssh_config $host -O exit
      #
      # ssh -F ssh_config $host -O forward -L ....
      # ssh -F ssh_config $host -O cancel -L ....
      programs.ssh =
        let
          matchexec_host = host: ip: port: {
            inherit host port;
            match = "originalhost ${host} Exec \"nc -w 1 -z ${ip} ${toString port} 1>&2 >/dev/null\"";
            hostname = ip;
            proxyCommand = "none";
            HostKeyAlias = host;
          };
          ## https://superuser.com/a/1635657
          home_host = Host: ip: Port: vpn_ip: mac: {
            ## Coming from localhost.
            "Match originalhost ${Host} exec \"[ %h = %L ]\"".LocalCommand =
              "echo \"SSH %n: To localhost\" >&2";
            ## Coming from outside home network.
            "Match originalhost ${Host} !exec \"[ %h = %L ]\" !exec \" ip neigh | grep REACHABLE | grep -Fw ${mac}\" !exec \"ip route | grep ${vpn_ip}\"" =
              lib.hm.dag.entryAfter [ "Match originalhost ${Host} exec \"[ %h = %L ]\"" ] {
                LocalCommand = "echo \"SSH %n: From outside network, to %h\" >&2";
                ProxyJump = lib.mkIf (Host != "rpi41") "rpi41";
                HostName = lib.mkIf (Host == "rpi41") "82.64.121.168";
                Port = lib.mkIf (Host == "rpi41") 443;

              };
            ## Coming from VPN
            "Match originalhost ${Host} !exec \"[ %h = %L ]\" !exec \" ip neigh | grep REACHABLE | grep -Fw ${mac}\" exec \"ip route | grep ${vpn_ip}\"" =
              lib.hm.dag.entryAfter
                [
                  "Match originalhost ${Host} !exec \"[ %h = %L ]\" !exec \" ip neigh | grep REACHABLE | grep -Fw ${mac}\" !exec \"ip route | grep ${vpn_ip}\""
                ]
                {
                  PermitLocalCommand = "yes";
                  LocalCommand = "echo \"SSH %n: From VPN network, to %h\" >&2";
                  ProxyCommand = "none";
                  HostName = "${vpn_ip}";
                  inherit Port;
                };
            ## Coming from inside home network.
            "Host ${Host}" =
              lib.hm.dag.entryAfter
                [
                  "Match originalhost ${Host} !exec \"[ %h = %L ]\" !exec \" ip neigh | grep REACHABLE | grep -Fw ${mac}\" exec \"ip route | grep ${vpn_ip}\""
                ]
                {
                  inherit Host Port;
                  PermitLocalCommand = "yes";
                  LocalCommand = "echo \"SSH %n: From home network, to %h\" >&2";
                  HostName = "${ip}";
                };
          };
        in
        {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "*" = {
              IdentitiesOnly = true;
              #IdentityFile id_dsa
              PasswordAuthentication = false;
              PubkeyAuthentication = true;
              TCPKeepAlive = true;
              SendEnv = "COLORTERM";
              Compression = true;
              ControlMaster = "auto";
              ControlPath = "/run/user/%i/socket-%C";
              ControlPersist = "4h";
            };

            "Host * Exec \"test -e ~/.ssh/extra_config\"" = lib.hm.dag.entryBefore [ "*" ] {
              Include = "~/.ssh/extra_config";
            };

            "127.0.0.1 | localhost" = {
              ForwardAgent = true;
              ForwardX11 = true;
              ForwardX11Trusted = true;
              NoHostAuthenticationForLocalhost = "yes";
            };
          }
          // (home_host "rpi31" "192.168.1.13" 22322 "10.147.27.13" "b8:27:eb:46:86:14")
          // (home_host "rpi41" "192.168.1.14" 22322 "10.147.27.14" "dc:a6:32:67:dd:9f")
          // (home_host "t580" "192.168.1.17" 22322 "10.147.27.17" "d2:b6:17:1d:b8:97")
          // (home_host "titan" "192.168.1.24" 22322 "10.147.27.24" "be:f8:2c:e5:1d:4e");
        };

      programs.git.iniContent.annex.ssh-options = "-S /run/user/%i/socket-%C";

    };
}
