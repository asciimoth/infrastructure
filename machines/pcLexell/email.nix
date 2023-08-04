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
  environment.systemPackages = with pkgs; [
    #thunderbird
    himalaya
  ];
  home-manager.users."${constants.MainUser}".programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
    settings = {
      "privacy.donottrackheader.enabled" = true;
    };
  };
}
