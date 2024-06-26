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
  # https://discourse.nixos.org/t/thinkpad-t470s-power-management/8141/8
  boot.kernelModules = ["coretemp" "cpuid"];

  boot.extraModprobeConfig = lib.mkMerge [
    # idle audio card after one second
    "options snd_hda_intel power_save=1"
    # enable wifi power saving (keep uapsd off to maintain low latencies)
    #"options iwlwifi power_save=1 uapsd_disable=1"
  ];

  environment.systemPackages = with pkgs; [
    autorandr
    powertop
    acpid
  ];

  services = {
    upower.enable = true;
    thermald.enable = true;
    acpid.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = lib.mkForce "ondemand"; # ondemand or performance or powersave
    resumeCommands = ''
      ${pkgs.autorandr}/bin/autorandr -c
    '';
  };
}
