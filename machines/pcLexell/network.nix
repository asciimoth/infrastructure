# Infrastructure config by ASCIIMoth
#
# To the extent possible under law, the person who associated CC0 with
# this work has waived all copyright and related or neighboring rights
# to it.
#
# You should have received a copy of the CC0 legalcode along with this
# work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  meshnamed = pkgs.callPackage ./pkjs/meshnamed {};
in {
  #environment.systemPackages = [ meshnamed ];
  networking = {
    #proxy.default = constants.Promux1Socks;
    usePredictableInterfaceNames = true;
    #useDHCP = true;
    enableIPv6 = true;
    dhcpcd = {
      enable = true;
      extraConfig = "\nnoipv6rs \nnoipv6 \nnohook resolv.conf";
    };
    useHostResolvConf = false;
    #tcpcrypt.enable = true;
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      dns = "none";
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
      # dispatcherScripts  # https://github.com/cyplo/dotfiles/blob/master/nixos/common-hardware.nix
    };
    # https://code.visualstudio.com/docs/setup/network#_common-hostnames
    extraHosts = ''
      78.153.130.171 hearty-health
      100.83.35.101 pinas
    '';
    # 192.168.1.141 pinas
    # 192.168.1.141 pipebomb.local
    # 100.66.72.81 pipebomb.local
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [5900 5001];
      allowedTCPPortRanges = lib.mkForce [];
      allowedUDPPorts = lib.mkForce [5001];
      allowedUDPPortRanges = lib.mkForce [];
      trustedInterfaces = lib.mkForce ["lo"]; #open all ports on localhost
      #extraCommands = "ip6tables -A INPUT -s fe80::/10 -j ACCEPT";
    };
    nameservers = ["8.8.8.8"];
    #nameservers = ["127.0.0.1" "::1"];
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = ["127.0.0.1:53" "[::1]:53"];
      max_clients = 256;
      ipv4_servers = true;
      ipv6_servers = true;
      block_ipv6 = false;
      dnscrypt_servers = true;
      doh_servers = true;
      odoh_servers = true;
      require_dnssec = false;
      require_nofilter = true;
      require_nolog = false;
      cache = true;
      cache_size = 8192;
      #cache_min_ttl = 2400;
      #cache_max_ttl = 86400;
      #cache_neg_min_ttl = 60;
      #cache_neg_max_ttl = 600;
      force_tcp = true;
      timeout = 5000;
      keepalive = 60; # DoT/DoH/ODoH
      dnscrypt_ephemeral_keys = true;
      tls_disable_session_tickets = true;
      bootstrap_resolvers = [
        "8.8.8.8:53"
        "9.9.9.9:53"
        "1.1.1.1:53"
      ];
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          "https://download.dnscrypt.info/dnscrypt-resolvers/v3/opennic.md"
          #"https://download.dnscrypt.info/dnscrypt-resolvers/v3/onion-services.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      server_names = [
        #"google"
        #"cloudflare"
        "doh-ibksturm"
        "publicarray-au2-doh"
        "adguard-dns-doh"
        "ahadns-doh-nl"
        "ahadns-doh-la"
        "ams-ads-doh-nl"
        "adguard-dns-doh"
      ];
      disabled_server_names = ["yandex"];
      forwarding_rules = "/etc/forwarding-rules";
    };
  };
  services.tailscale.enable = true;

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  environment.etc.forwarding-rules.text = ''
    meshname 127.0.0.1:5353
    meship 127.0.0.1:5353
  '';

  systemd.services.meshnamed = {
    #path = with pkgs; [];
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    description = "Resolve meshname and meship domains";
    serviceConfig = {
      Type = "simple";
      User = "nobody";
      ExecStart = "${meshnamed}/bin/meshnamed -listenaddr 127.0.0.1:5353";
    };
  };

  services.tor = {
    enable = true;
    client.enable = true;
  };
}
