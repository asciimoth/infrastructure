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
    home.file.".config/awesome".source = ../awesome;
    xsession.windowManager.command = "${pkgs.awesome}/bin/awesome";
  };
}
