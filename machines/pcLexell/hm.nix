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
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.root.home.stateVersion = config.system.stateVersion;
  home-manager.users.${constants.MainUser} = {
    home.stateVersion = config.system.stateVersion;
    systemd.user.tmpfiles.rules = [
      "L+    /home/${constants.MainUser}/mnt                   -    -    -     -           /run/media/${constants.MainUser}"
    ];
  };
}
