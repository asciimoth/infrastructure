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
  chownd = pkgs.writeShellScriptBin "chownd" (builtins.readFile ./chownd.sh);
in {
  #
  systemd.services.chownd = {
    path = with pkgs; [coreutils gawk];
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target"];
    description = "Change owner";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${chownd}/bin/chownd";
    };
  };
}
