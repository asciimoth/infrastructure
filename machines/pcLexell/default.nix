# Infrastructure config by DomesticMoth
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
  hostname,
  ...
}: let
  constants = import ./constants.nix;
in {
  imports = [
    ./hm.nix
    #./initrd.nix
    ./shell.nix
    ./git.nix
    ./hardening.nix
    ./nosleep.nix
    ./sound.nix
    ./power.nix
    ./x.nix

    #./ssh.nix

    ../../names

    # Generic. Include the results of the hardware scan.
    ./configuration.nix
  ];

  # Pin nixpkgs
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  networking.hostName = hostname;
  time.timeZone = "Asia/Tbilisi";

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings.auto-optimise-store = true;
  #nix.binaryCashes = lib.mkForce [ "https://cashe.nixos.org" ];

  system.autoUpgrade.enable = lib.mkForce false;

  boot = {
    cleanTmpDir = true;
    consoleLogLevel = 0; # Show all levels
  };

  users = {
    mutableUsers = false;
    users = {
      root.password = "root";
      "${constants.MainUser}" = {
        uid = 1000;
        isNormalUser = true;
        home = "/home/moth";
        createHome = true;
        extraGroups = [
          "wheel" # For sudo
          "audio"
          "sound"
          "video"
          "docker"
          #"input"
          #"tty"
          "power" # For shutdown/reboot immideatly without sudo
          #"games"
          #"scanner"
          #"storage"
          #"optical"
          "networkmanager"
          #"vboxusers"
        ];
        # Warning: security issue
        # Note: This is a temporal solution used only as long as config is under development
        # TODO Use imperative user password managment in production
        #password = "${constants.MainUser}";
        hashedPassword = "$5$SALTSALT$k4y1u90hZBQ3yYjQXwA/VHNnOKIO9.mzeiShw5uEyo9";
      };
    };
    users.root.hashedPassword = null;
  };

  security.sudo = {
    enable = true;
    #configFile = ''
    #  %wheel ALL=(ALL) ALL
    #'';
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.dnsname.enable = true;
    #defaultNetwork.settings.dns_enabled = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "python3.10-certifi-2022.12.7"
  ];

  environment.systemPackages = with pkgs; [
    htop
    micro
    nano
    age
    rage
    tomb
    b3sum
    openssl
    cryptsetup
    neofetch
    pulseaudio

    tmate
    thefuck
    perl
    alacritty

    firefox

    nebula

    distrobox

    nixopsUnstable

    imhex

    gping

    go

    alejandra # nix formatter

    # For make Qt 5 apps look similar to GTK2 ones
    #qt5.qtbase.gtk
  ];

  programs.ssh.askPassword = ""; # Ask with CLI but not GUI dialog

  console = {
    earlySetup = true;
    packages = with pkgs; [terminus_font];
    font = "ter-u16n";
  };

  nixpkgs.config.allowUnfree = true; # Forgive me Stallman

  home-manager.users.root = {pkgs, ...}: {
    home.file.".config/micro/settings.json".source = ./micro/settings.json;
    home.file.".config/micro/bindings.json".source = ./micro/bindings.json;
  };

  home-manager.users."${constants.MainUser}" = { pkgs, ... }: {
    home.file.".config/micro/settings.json".source = ./micro/settings.json;
    home.file.".config/micro/bindings.json".source = ./micro/bindings.json;
  };

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true; #Will force recompile some programs
    fonts = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode" "FiraMono"];})
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["FiraCode Nerd Font Mono"];
        sansSerif = ["FiraCode Nerd Font Mono"];
        monospace = ["FiraCode Nerd Font Mono"];
      };
    };
  };

  zramSwap = {
    enable = true;
    priority = 1000;
    algorithm = "zstd";
    #numDevices = 1;
    swapDevices = 1;
    memoryPercent = 50;
  };

  hardware.ksm.enable = true;

  documentation = {
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
  };

  hardware.enableRedistributableFirmware = true;

  environment.variables = {
    CONFIGROOT = "${constants.ConfigRoot}";
  };

  networking = {
    usePredictableInterfaceNames = true;
    enableIPv6 = true;
    dhcpcd = {
      enable = true;
      extraConfig = "\nnoipv6rs \nnoipv6 \nnohook resolv.conf";
    };
    useHostResolvConf = false;
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      dns = "none";
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
    };
    extraHosts = "";
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [];
      allowedUDPPorts = lib.mkForce [];
      trustedInterfaces = lib.mkForce ["lo"];
    };
    nameservers = ["8.8.8.8"];
    #nameservers = [ "127.0.0.1" "::1" ];
  };
}
