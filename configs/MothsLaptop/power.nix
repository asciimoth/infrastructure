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
