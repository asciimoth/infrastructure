{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./xmonad
  ];

  services.xserver = {
    enable = true;
    autorun = false;
    exportConfiguration = true;
    libinput.enable = true;
    layout = "us,ru";
    xkbOptions = "grp:shifts_toggle";
    #windowManager.awesome = {
    #	enable = true;
    #	luaModules = with pkgs.luaPackages; [
    #		luarocks # package manager
    #		luadbi-mysql
    #	];
    #};
    displayManager = {
      lightdm.enable = lib.mkForce false;
      startx.enable = true;
      #autoLogin = {
      #  enable = true;
      #  user = "moth";
      #};
    };
    videoDrivers = [
      "nvidia"
      "ati_ufree"
      "amdgpu"
    ];
  };

  environment.etc.wallaper.source = ./GreyDot.png;

  home-manager.users.moth.xsession = {
  	enable = true;
  	scriptPath = ".xinitrc";
  };
  #home-manager.users.moth.home.file.".config/awesome".source = "./awesome";

  #environment.shellAliases.initx = "xinit -- -xkbdir /etc/X11/xkb";

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };
}
