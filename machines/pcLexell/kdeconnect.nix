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
  environment.systemPackages = with pkgs; [
    #dcnnt
    # dcnnt has very insecure code, so it should be run it in isolation
    boxxy
    (pkgs.writeShellScriptBin "dcnnt" ''
      ${dcnnt}/bin/dcnnt
    '')
  ];
  networking.firewall = {
    allowedTCPPorts = lib.mkForce [5040];
    allowedTCPPortRanges = lib.mkForce [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPorts = lib.mkForce [5040];
    allowedUDPPortRanges = lib.mkForce [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };
}
