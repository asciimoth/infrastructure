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
      100.83.35.101 pinas
    '';
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [22 5900 5001];
      allowedTCPPortRanges = lib.mkForce [];
      allowedUDPPorts = lib.mkForce [5001];
      allowedUDPPortRanges = lib.mkForce [];
      trustedInterfaces = lib.mkForce ["lo"]; #open all ports on localhost
      #extraCommands = "ip6tables -A INPUT -s fe80::/10 -j ACCEPT";
    };
    nameservers = ["8.8.8.8"];
    #nameservers = ["127.0.0.1" "::1"];
  };

  services.tailscale.enable = true;

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
}
