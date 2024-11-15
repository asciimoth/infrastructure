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
  hostname,
  master,
  ...
}: let
  constants = import ./constants.nix;
in {
  imports = [
    ./time.nix
    ./hm.nix
    ./initrd.nix
    ./shell.nix
    ./git.nix
    ./gpg.nix
    ./yubic.nix
    ./hardening.nix
    ./nosleep.nix
    ./sound.nix
    ./power.nix
    ./i18n.nix
    #./x.nix
    ./gui.nix
    ./network.nix
    ./example.nix
    ./theme.nix
    ./usb.nix
    ./email.nix
    ./qr.nix
    #./kdeconnect.nix
    ./text.nix
    ./dev.nix
    ./steam.nix
    ./ranger.nix
    ./desel.nix
    ./dot.nix

    #./ssh.nix
    ./ssh_client.nix

    ../../names
    ./chownd.nix
    ./local_auth.nix

    ./controlbox.nix

    # Generic. Include the results of the hardware scan.
    ./configuration.nix
  ];

  # Pin nixpkgs
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  networking.hostName = hostname;

  nix.package = pkgs.nixVersions.latest;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings.auto-optimise-store = true;
  #nix.binaryCashes = lib.mkForce [ "https://cashe.nixos.org" ];

  boot = {
    consoleLogLevel = 0; # Show all levels
  };

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";

  users = {
    mutableUsers = false;
    users = {
      root.hashedPassword = "*";
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
          "fuse"
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
        # I use pam_u2f so I dont need for passwords
        # But nixos anyway requires it
        # So this is the hash of a random 300 bit combination
        #   that has never saved anywhere
        hashedPassword = "$6$ORI3ESpCJxOGlGYG$ophduthBXVVkUU7SOAZoWD.OuhyUPzJ07ZyoccH2Sc9.Ef45MJfUG9HBcO8KEgKhmi4h9ZcSdyHmRXrNGdmaH0";
      };
    };
  };

  security = {
    sudo = {
      enable = true;
      #configFile = ''
      #  %wheel ALL=(ALL) ALL
      #'';
    };
    doas = {
      enable = true;
    };
  };

  virtualisation = {
    libvirtd.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      #defaultNetwork.dnsname.enable = true; #deprecated
      defaultNetwork.settings.dns_enabled = true;
      autoPrune.enable = true;
      #defaultNetwork.settings.dns_enabled = true;
      #extraOptions = "--iptables=false"; # Makes shure that Podman/Docker doesn't alter the firewall
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "python3.10-certifi-2022.12.7"
    "electron-25.9.0"
    # "openssl-1.1.1w" # For sublime text
    "olm-3.2.16"
  ];

  boot.supportedFilesystems = ["ntfs"];

  environment.systemPackages = with pkgs; [
    luajitPackages.jsregexp
    gh
    zoxide
    skim
    fd
    alacritty
    htop
    btop
    nvtopPackages.full
    glances
    age
    rage
    sops
    b3sum
    openssl
    neofetch
    cpufetch
    pulseaudio
    strace
    copyq # clipboard manager
    wget
    curl
    alejandra

    nix-tree

    smartmontools

    tmate
    thefuck
    #perl

    #nebula

    #distrobox

    #nixopsUnstable

    #imhex

    gping

    #go

    #master.boxxy
    boxxy
    tmux
    tab-rs

    duf # Disk Usage Utility

    nmap

    lshw # Provides detailed inforamtion about hardware
    lsof # A tool to list open files

    #smartmontools #smartmontools

    #sshfs

    usbutils #lsusb & CO

    jq

    xdotool

    drawio

    #zathura

    #udisksctludisksctl

    # yara

    #entr # Run commands when files change

    #gqview #image viewer

    # For make Qt 5 apps look similar to GTK2 ones
    #qt5.qtbase.gtk

    #gcc
    #rustup
    #rustc
    #cargo
    #cargo-license

    #zig
    #master.yazi

    wireshark
    wireguard-tools

    # Drawing
    krita
    inkscape
    xournal

    skrooge
    libreoffice-fresh

    iperf2
    inetutils

    uget

    # Typing traning
    #smassh
    typespeed
    #gtypist
    #typer
    #ttyper
    #toipe
    #klavaro
    #typioca
    #amphetype
    #tipp10
    #wpm
    #thokr

    unzip

    goxel

    # Ai
    llama-cpp
    ollama
    # Term clients
    oterm # Ollama terminal client
    aichat # Terminal frontend for ollama, ChatGPT, etc
    gpt4all
    jan # Jan is an open source alternative to ChatGPT that runs 100% offline on your computer
    zathura
  ];

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

  home-manager.users."${constants.MainUser}" = {pkgs, ...}: {
    home.file.".config/micro/settings.json".source = ./micro/settings.json;
    home.file.".config/micro/bindings.json".source = ./micro/bindings.json;
    programs = {
      zathura.enable = false;
    };
  };

  programs = {
    command-not-found.enable = false;
    nix-index = {
      enable = true;
      # enableBashIntegration = true;
      #enableFishIntegration = true;
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

  hardware = {
    ksm.enable = true;
    nvidia-container-toolkit.enable = true;
  };

  # Need for faster builds
  documentation = {
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      man-db.enable = true;
    };
  };

  # CUPS
  # nixos.wiki/wiki/Printing
  #services.printing = {
  #  enable = true;
  #  drivers = with pkgs; [
  #    hplipWithPlugin
  #  ];
  #};

  # Scaning
  #hardware.sane = {
  #  enable = true;
  #  extraBackends = with pkgs; [
  #    hplipWithPlugin
  #  ];
  #};

  environment.variables = {
    CONFIGROOT = "${constants.ConfigRoot}";
    EDITOR = "${constants.Editor}";
    VISUAL = "${constants.Editor}";
  };

  environment.etc."chownd/infr" = {
    text = "moth ${constants.ConfigRoot}";
    mode = "744";
  };
}
