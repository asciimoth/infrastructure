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
}: let
  constants = import ./constants.nix;
in {
  imports = [
    ./i3.nix
  ];

  services = {
    libinput.enable = true;
    xserver = {
      enable = true;
      autorun = false;
      exportConfiguration = true;
      #libinput.enable = true;
      xkb.layout = "us,ru";
      xkb.options = "grp:caps_toggle";
      #xkb.options = "grp:shifts_toggle";
      dpi = 141; #https://dpi.lv/
      displayManager = {
        lightdm.enable = lib.mkForce false;
        startx.enable = true;
        #autoLogin = {
        #  enable = true;
        #  user = "moth";
        #};
        sessionCommands = ''
        '';
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
    dbus.enable = true;
    #tumbler.enable = true;
  };

  #environment.etc.wallaper.source = ./GreyDot.png;

  home-manager.users."${constants.MainUser}".xsession = {
    enable = true;
    scriptPath = ".xinitrc";
  };

  hardware = {
    graphics = {
      enable = true;
      #driSupport = true; # Deprecated
      enable32Bit = true;
      #extraPackages = with pkgs; [
      #  vaapiVdpau
      #  libvdpau-va-gl
      #];
      #extraPackages32 = with pkgs.pkgsi686Linux; [libva];
      #setLdLibraryPath = true;
    };
    nvidia = {
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      #forceFullCompositionPipeline = true;
      powerManagement.enable = true;
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
