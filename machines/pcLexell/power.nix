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
  environment.systemPackages = with pkgs; [
    autorandr
  ];

  services.upower.enable = true;

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = lib.mkForce "powersave"; # or performance
    resumeCommands = ''
      ${pkgs.autorandr}/bin/autorandr -c
    '';
  };
}
