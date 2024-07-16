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
  mutespeaker = pkgs.writeShellScriptBin "mutespeaker" (builtins.readFile ./mutespeaker.sh);
  constants = import ./constants.nix;
in {
  imports = [
    ./mpd.nix
  ];

  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mutespeaker
    moc
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  #home-manager.users."${constants.MainUser}" = {
  #  programs = {
  #    mocp.enable = true;
  #  };
  #};

  systemd.user.services = {
    mutespeaker = {
      enable = false;
      wantedBy = ["default.target"];
      after = ["network.target"];
      #description = "";
      path = with pkgs; [
        pulseaudio
        mutespeaker
        bash
      ];
      #environment = {};
      serviceConfig = {
        #User = "moth";
        ExecStart = "${mutespeaker}/bin/mutespeaker";
        #ExecStart = "bash -c '${mutespeaker}/bin/mutespeaker >> /home/moth/log/mutespeaker &>> /home/mot/log/mutespeaker'";
        Restart = "always";
        RestartSec = 10;
      };
    };
    mpris-proxy = {
      enable = true;
      wantedBy = ["default.target"];
      after = ["network.target" "sound.target"];
      description = "Mpris proxy";
      serviceConfig = {
        ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      };
    };
  };
}
