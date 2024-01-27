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
  xdot-desktop = pkgs.makeDesktopItem {
    name = "xdot";
    desktopName = "xdot";
    exec = "${pkgs.xdot}/bin/xdot";
    terminal = false;
  };
in {
  environment.systemPackages = with pkgs; [
    graphviz
    xdot
    xdot-desktop
  ];
}
