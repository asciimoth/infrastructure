{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  services.xserver = {
    windowManager.i3 = {
      enable = true;
    };
    displayManager.defaultSession = "none+i3";
  };

  home-manager.users.moth = {pkgs, ...}: {
    xsession.windowManager.command = ''
      # See init.fish oncecall function
      export ONCECALL="/tmp/oncecall-moth"
      picom -b
      ${pkgs.i3}/bin/i3;
    '';
  };

  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    picom
    brightnessctl
  ];
}
