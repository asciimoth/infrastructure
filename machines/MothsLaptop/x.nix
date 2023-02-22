{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./awesome
  ];

  services.xserver = {
    enable = true;
    autorun = false;
    exportConfiguration = true;
    libinput.enable = true;
    layout = "us,ru";
    xkbOptions = "grp:shifts_toggle";
    displayManager = {
      lightdm.enable = lib.mkForce false;
      startx.enable = true;
      #autoLogin = {
      #  enable = true;
      #  user = "moth";
      #};
    };
    videoDrivers = [
      #"nvidia"
      #"ati_ufree"
      #"amdgpu"
    ];
  };

  environment.etc.wallaper.source = ./GreyDot.png;

  home-manager.users.moth.xsession = {
    enable = true;
    scriptPath = ".xinitrc";
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };
}
