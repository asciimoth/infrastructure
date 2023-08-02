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
  imports = [
    ./awesome
  ];

  services = {
    xserver = {
      enable = true;
      autorun = false;
      exportConfiguration = true;
      libinput.enable = true;
      layout = "us,ru";
      xkbOptions = "grp:shifts_toggle";
      dpi = 141; #https://dpi.lv/
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
        #"amdgpu"
      ];
      excludePackages = with pkgs; [
        xterm
      ];
    };
    hardware.bolt.enable = false;
  };

  #environment.etc.wallaper.source = ./GreyDot.png;

  home-manager.users.moth.xsession = {
    enable = true;
    scriptPath = ".xinitrc";
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      #open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      #package = config.boot.kernelPackages.nvidiaPackages.stable; #Optional
    };
  };

  #services.unclutter = {
  #  enable = true;
  #  threshold = 2;
  #  timeout = 1;
  #  extraOptions = [
  #    "ignore-scrolling"
  #  ];
  #};
}
