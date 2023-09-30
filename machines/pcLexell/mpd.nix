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
  services.mpd = {
    enable = true;
    musicDirectory = "/home/${constants.MainUser}/mpd";
    user = "${constants.MainUser}";
    extraConfig = ''
      auto_update "no"
      restore_paused "yes"
      audio_output {
        type "pipewire"
        name "${constants.MainUser} PipeWire Output"
      }
    '';
    #network.listenAddress = "any"; # if you want to allow non-localhost connections
    #startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
  };
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/1000";
  };
  environment.systemPackages = with pkgs; [
    ncmpcpp
    mpc-cli
  ];
}
