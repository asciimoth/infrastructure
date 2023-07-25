{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  services.xserver = {
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # package manager
        luadbi-mysql
      ];
    };
    displayManager.defaultSession = "none+awesome";
  };

  home-manager.users.moth = {pkgs, ...}: {
    home.file.".config/awesome".source = ./awesome;
    xsession.windowManager.command = ''
      export AWESOME_THEMES_PATH="/home/moth/.config/awesome/themes"
      # See init.fish oncecall function
      export ONCECALL="/tmp/oncecall-moth"
      picom -b
      ${pkgs.awesome}/bin/awesome;
    '';
  };

  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    picom
    brightnessctl
  ];
}
