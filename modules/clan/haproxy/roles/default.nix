{ config, lib, pkgs, inputs, ... }:
let
  haproxy_internal_ip = "192.168.127.254";
in
{
  networking.firewall.allowedTCPPorts = [ 443 ];
  systemd.network.netdevs."40-haproxy" = {
    netdevConfig = {
      Name = "haproxy";
      Kind = "dummy";
    };
  };
  systemd.network.networks."40-haproxy" = {
    name = "haproxy";
    networkConfig.Address = "${haproxy_internal_ip}/32";
    routingPolicyRules = [
      {
        From = "${haproxy_internal_ip}";
        Table = "103";
      }
    ];
    routes = [
      {
        Destination = "0.0.0.0/0";
        Type = "local";
        Table = "103";
      }
    ];
  };
  services.haproxy.enable = true;
  ### https://datamakes.com/2018/02/17/high-intensity-port-sharing-with-haproxy/
  services.haproxy.config = ''
    defaults
      log  global
      timeout connect 10s
      timeout client 36h
      timeout server 36h
    global
      log /dev/log  local0 debug

    listen sslh
      mode tcp
      bind 0.0.0.0:443 transparent
      tcp-request inspect-delay 15s
      tcp-request content accept if { req.ssl_hello_type 1 }

      #acl    ssh_payload        payload(0,7)    -m bin 5353482d322e30
      acl ssh_payload req.payload(0,7) -m str "SSH-2.0"
      #tcp-request content reject if !ssh_payload
      #tcp-request content accept if { req_ssl_hello_type 1 }

      use_backend openssh            if ssh_payload
      use_backend openssh            if !{ req.ssl_hello_type 1 } { req.len 0 }
      use_backend shadowsocks        if !{ req.ssl_hello_type 1 } !{ req.len 0 }
      timeout client 2h
      log global

    backend openssh
      mode tcp
      server openssh ${haproxy_internal_ip}:44322 source 0.0.0.0 usesrc clientip
      timeout server 2h
      log global
    backend shadowsocks
      mode tcp
      server socks ${haproxy_internal_ip}:${toString config.services.shadowsocks.port} source 0.0.0.0 usesrc clientip
      log global
  '';
  services.haproxy.user = "root"; # for transparent
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.listenAddresses = [
    { addr = "127.0.0.1"; port = 44322; }
    { addr = "${haproxy_internal_ip}"; port = 44322; }
  ];

  #echo -n "ss://"`echo -n chacha20-ietf-poly1305:$(sops --extract '["shadowsocks"]' -d hosts/rpi31/secrets/secrets.yaml)@$(curl -4 ifconfig.io):443 | base64` | qrencode -t UTF8
  services.shadowsocks = {
    enable = true;
    localAddress = [ haproxy_internal_ip ];
    port = 8388;
    passwordFile = config.sops.secrets.shadowsocks.path;
  };
}
