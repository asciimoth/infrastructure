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
  controlbox = pkgs.writeShellScriptBin "controlbox" ''
    ${pkgs.wezterm}/bin/wezterm start --class CONTROLBOX -e ${pkgs.fish}/bin/fish -c "source /etc/theme.fish && base16-load && $*"
  '';
in {
  environment.systemPackages = with pkgs; [controlbox];
}
