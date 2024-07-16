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
    ./shell.nix
    ./git.nix
    ./nosleep.nix
    ./i18n.nix
    ./network.nix
    ./text.nix
    ./chownd.nix

    ./ssh.nix
    ./ssh_client.nix

    # Generic. Include the results of the hardware scan.
    ./configuration.nix
  ];

  # Pin nixpkgs
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  networking.hostName = hostname;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings.auto-optimise-store = true;
  #nix.binaryCashes = lib.mkForce [ "https://cashe.nixos.org" ];

  boot = {
    consoleLogLevel = 0; # Show all levels
  };

  #sops.age.keyFile = "/root/.config/sops/age/keys.txt";

  users = {
    mutableUsers = false;
    users = {
      root.hashedPassword = "*";
      "${constants.MainUser}" = {
        uid = 1000;
        isNormalUser = true;
        home = "/home/${constants.MainUser}";
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
        #hashedPassword = "$6$ORI3ESpCJxOGlGYG$ophduthBXVVkUU7SOAZoWD.OuhyUPzJ07ZyoccH2Sc9.Ef45MJfUG9HBcO8KEgKhmi4h9ZcSdyHmRXrNGdmaH0";
      };
    };
  };

  security = {
    sudo = {
      enable = true;
      configFile = ''
        %wheel ALL=(ALL) ALL
      '';
    };
    doas = {
      enable = true;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "python3.10-certifi-2022.12.7"
    "electron-25.9.0"
  ];

  boot.supportedFilesystems = ["ntfs"];

  environment.systemPackages = with pkgs; [
    htop
    btop
    age
    rage
    sops
    b3sum
    openssl
    neofetch
    cpufetch
    strace
    wget
    curl

    nix-tree

    tmate
    thefuck

    gping

    tab-rs

    duf # Disk Usage Utility

    nmap

    lshw # Provides detailed inforamtion about hardware
    lsof # A tool to list open files

    usbutils #lsusb & CO

    jq

    iperf2
    inetutils

    unzip
  ];

  console = {
    earlySetup = true;
    packages = with pkgs; [terminus_font];
    font = "ter-u16n";
  };

  nixpkgs.config.allowUnfree = true; # Forgive me Stallman

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
    man = {
      enable = true;
      man-db.enable = true;
    };
  };

  environment.variables = {
    CONFIGROOT = "${constants.ConfigRoot}";
    EDITOR = "${constants.Editor}";
    VISUAL = "${constants.Editor}";
  };

  environment.etc."chownd/infr" = {
    text = "${constants.MainUser} ${constants.ConfigRoot}";
    mode = "744";
  };
}
