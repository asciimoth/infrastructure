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
}: {
  environment.systemPackages = [
    (pkgs.callPackage ./pkjs/meshnamed {})
  ];
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
    extraHosts = "";
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [];
      allowedUDPPorts = lib.mkForce [];
      trustedInterfaces = lib.mkForce ["lo"]; #open all ports on localhost
      #extraCommands = "ip6tables -A INPUT -s fe80::/10 -j ACCEPT";
    };
    #nameservers = [ "8.8.8.8"];
    nameservers = ["127.0.0.1" "::1"];
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      cache_size = 8192;
      #cache_min_ttl = 2400;
      #cache_max_ttl = 86400;
      #cache_neg_min_ttl = 60;
      #cache_neg_max_ttl = 600;
      require_dnssec = true;
      require_nofilter = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          "https://download.dnscrypt.info/dnscrypt-resolvers/v3/opennic.md"
          #"https://download.dnscrypt.info/dnscrypt-resolvers/v3/onion-services.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      server_names = [
        "google"
        "cloudflare"
      ];
      forwarding_rules = "/etc/forwarding-rules";
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  environment.etc.forwarding-rules.text = ''
    meshname 127.0.0.1:5353
    meship 127.0.0.1:5353
  '';
}
