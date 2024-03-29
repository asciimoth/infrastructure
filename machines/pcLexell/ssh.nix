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
  environment.systemPackages = with pkgs; [];
  users.users.moth = {
    #openssh.authorizedKeys.keys = [];
  };
  services.openssh = {
    enable = true;
    #passwordAuthentication = true;
    #kbdInteractiveAuthentication = lib.mkForce true;
    #permitRootLogin = lib.mkForce "yes";
  };
}
