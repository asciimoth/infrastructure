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
  wezterm-desktop = pkgs.makeDesktopItem {
    name = "wezterm";
    desktopName = "wezterm";
    exec = "${pkgs.wezterm}/bin/wezterm";
    terminal = false;
  };
  copyscreen = pkgs.writeShellScriptBin "copyscreen" ''
    TMPFILE="/tmp/copyscreen-$(${pkgs.openssl}/bin/openssl rand 40 | base32).png"
    ${pkgs.flameshot}/bin/flameshot gui -r > $TMPFILE
    file2clip $TMPFILE
    rm -rf $TMPFILE
  '';
in {
  imports = [
    ./x.nix
    ./firefox.nix
    ./matrix.nix
    ./chromium.nix
  ];
  environment.systemPackages = with pkgs; [
    notify-desktop
    xorg.xbacklight
    xorg.xdpyinfo
    flameshot
    copyscreen
    obsidian
    tor-browser-bundle-bin
    #hyprdim
    gthumb # image viewver; automatically bind to xdg
    mpv # Video player
    eww
  ];
  programs.hyprland = {
    #enable = true;
    nvidiaPatches = true;
    xwayland = {
      hidpi = true;
      enable = true;
    };
  };
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        pass-secret-service
      ];
    };
    mime = let
      defaultApplications = {
        browser = {
          cmd = "${pkgs.firefox}/bin/firefox";
          desktop = "firefox";
        };
        matrix = {
          cmd = "${pkgs.nheko}/bin/nheko";
          desktop = "nheko";
        };
        editor = {
          cmd = "${pkgs.micro}/bin/micro ${pkgs.micro}/bin/micro";
          desktop = "micro";
        };
        fm = {
          cmd = "ranger";
          desktop = "ranger";
        };
        terminal = {
          cmd = "${pkgs.wezterm}/bin/wezterm";
          desktop = "WezTerm";
        };
      };
    in {
      enable = true;
      defaultApplications = with defaultApplications;
        builtins.mapAttrs
        (name: value:
          if value ? desktop
          then ["${value.desktop}.desktop"]
          else value)
        {
          "x-terminal-emulator" = terminal;
          "inode/directory" = fm;
          "text/html" = browser;
          #"image/*" = { desktop = "org.gnome.eog"; };
          #"application/zip" = archive;
          #"application/rar" = archive;
          #"application/7z" = archive;
          #"application/*tar" = archive;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-www-browser" = browser;
          "application/pdf" = browser;
          #"x-scheme-handler/mailto" = mail;
          "x-scheme-handler/matrix" = matrix;
          #"application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          #  text_processor;
          #"application/msword" = text_processor;
          #"application/vnd.oasis.opendocument.text" = text_processor;
          #"text/csv" = spreadsheet;
          #"application/vnd.oasis.opendocument.spreadsheet" = spreadsheet;
          "text/plain" = editor;
        };
    };
  };
  home-manager.users."${constants.MainUser}" = {
    systemd.user.services.graphical-notify = {
      Service = {
        ExecStart = toString (pkgs.writeShellScript "graphical-notify" ''
          ${pkgs.coreutils-full}/bin/touch /tmp/graphical-notifyer
        '');
      };
      Unit = {
        Description = "Create /tmp/graphical-notifyer when graphical session starts";
        After = ["graphical-session.target"];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
    programs = {
      rofi = {
        enable = true;
        font = lib.mkForce "FiraCode Nerd Font Mono 14";
        #terminal = "wezterm";
      };
      wezterm = {
        enable = true;
        extraConfig = builtins.readFile ./wezTerm.lua;
      };
    };
    home.packages = [
      pkgs.tdesktop
    ];
    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
    home.sessionVariables = {
      TERMINAL = "wezterm";
      TERM = "wezterm";
    };
  };
}
