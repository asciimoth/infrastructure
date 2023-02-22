{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  services.xserver = {
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hpkgs: [];
      config = builtins.readFile ./xmonad.hs;
    };
    displayManager.defaultSession = "none+xmonad";
  };
  home-manager.users.moth.xsession.windowManager.command = "${pkgs.xmonad-with-packages}/bin/xmonad";
  #environment.etc."xmonad/conf.hs" = ./conf.hs;
}
