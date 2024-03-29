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
  constants = import ./constants.nix;
in {
  home-manager.users."${constants.MainUser}".systemd.user.services.desel = {
    Service = {
      ExecStart = toString (pkgs.writeShellScript "desel" ''
        while(true)
        do
            echo -n | ${pkgs.xsel}/bin/xsel -n -i
            ${pkgs.coreutils-full}/bin/sleep 0.5
        done
      '');
    };
    Unit = {
      Description = "Disable xclip selection";
      After = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
