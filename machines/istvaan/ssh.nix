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
  environment.systemPackages = with pkgs; [];
  users.users."${constants.MainUser}" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKY+ByohlwReapnPolsG+iVuK8Cj0Ve+VX7Ou1CJvRlF"
    ];
  };
  services.openssh = {
    enable = true;
  };
}
