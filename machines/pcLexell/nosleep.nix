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
  # Force disable sleep/hibenation/suspendion
  services.logind.lidSwitch = lib.mkForce "ignore";
  systemd.targets = {
    sleep.enable = lib.mkForce false;
    suspend.enable = lib.mkForce false;
    hibernate.enable = lib.mkForce false;
    hybrid-sleep.enable = lib.mkForce false;
  };
  boot.kernelParams = ["nohibernate"];
}
