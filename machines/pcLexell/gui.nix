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
    ./x.nix
    ./firefox.nix
    ./matrix.nix
    ./chromium.nix
  ];
  options = {
    defaultApplications = lib.mkOption {
      type = lib.types.attrs;
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      notify-desktop
      xorg.xbacklight
      xorg.xdpyinfo
      flameshot
      obsidian
      tor-browser-bundle-bin
    ];
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
        };
        alacritty = {
          enable = true;
          settings = {
            scale_with_dpi = true;
            dpi = {
              x = 141;
              y = 141;
            };
            font.size = lib.mkForce 8;
          };
        };
        wezterm = {
          enable = true;
          extraConfig = builtins.readFile ./wezTerm.lua;
        };
      };
      home.packages = [
        pkgs.tdesktop
      ];
    };

    xdg.mime = {
      enable = true;
      defaultApplications = with config.defaultApplications;
        builtins.mapAttrs
        (name: value:
          if value ? desktop
          then ["${value.desktop}.desktop"]
          else value)
        {
          #"inode/directory" = fm;
          "text/html" = browser;
          #"image/*" = { desktop = "org.gnome.eog"; };
          #"application/zip" = archive;
          #"application/rar" = archive;
          #"application/7z" = archive;
          #"application/*tar" = archive;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/mailto" = mail;
          #"x-scheme-handler/matrix" = matrix;
          #"application/pdf" = { desktop = "org.kde.okular"; };
          #"application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          #  text_processor;
          #"application/msword" = text_processor;
          #"application/vnd.oasis.opendocument.text" = text_processor;
          #"text/csv" = spreadsheet;
          #"application/vnd.oasis.opendocument.spreadsheet" = spreadsheet;
          "text/plain" = editor;
        };
    };
    defaultApplications = {
      matrix = {
        cmd = "${pkgs.nheko}/bin/nheko";
        desktop = "nheko";
      };
      browser = {
        cmd = "${pkgs.firefox}/bin/firefox";
        desktop = "firefox";
      };
      #fm = {
      #  cmd = "${pkgs.dolphin}/bin/dolphin";
      #  desktop = "org.kde.dolphin";
      #};
      editor = {
        cmd = "${pkgs.micro}/bin/micro ${pkgs.micro}/bin/micro";
        desktop = "micro";
      };
      mail = {
        cmd = "${pkgs.thunderbird}/bin/thunderbird";
        desktop = "thunderbird";
      };
      #text_processor = {
      #  cmd = "${pkgs.libreoffice}/bin/libreoffice";
      #  desktop = "libreoffice-startcenter";
      #};
      #spreadsheet = {
      #  cmd = "${pkgs.libreoffice}/bin/libreoffice";
      #  desktop = "libreoffice-startcenter";
      #};
      #archive = {
      #  cmd = "${pkgs.gnome.file-roller}/bin/file-roller";
      #  desktop = "org.gnome.FileRoller";
      #};
    };
  };
}
