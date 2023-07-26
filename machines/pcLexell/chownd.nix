# Infrastructure config by DomesticMoth
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
  configpath = "/etc/infrastructure";
in {
  #
  systemd.services.chownd = {
    wantedBy = [ "multi-user.target" ]; 
    after = [ "multi-user.target" ];
    description = "Change owner of ${configpath} to ${constants.MainUser}";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${pkgs.coreutils-full}/bin/chown -R ${constants.MainUser} ${configpath}";
    };
  };
}
