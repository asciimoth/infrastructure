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
      wezterm = {
        enable = true;
        extraConfig = builtins.readFile ./wezTerm.lua;
      };
    };
    home.packages = [
      pkgs.tdesktop
    ];
  };
}
