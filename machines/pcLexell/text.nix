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
  stlc = pkgs.writeShellScriptBin "stlc" (builtins.readFile ./stlc.sh);
in {
  environment.systemPackages = with pkgs; [
    nano
    micro
    sublime4
    ripgrep # Needs for nvim setup
    wmctrl
    #helix
  ];
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    #defaultEditor = true;
    #extraConfig = ''
    #  set number relativenumber
    #'';
  };
  #networking.extraHosts = ''
  #  0.0.0.0 www.sublimetext.com
  #  0.0.0.0 sublimetext.com
  #  0.0.0.0 forum.sublimetext.com
  #'';
  home-manager.users."${constants.MainUser}".systemd.user.services.stlc = {
    Service = {
      Environment = ["PATH=${lib.makeBinPath [pkgs.xorg.xprop pkgs.wmctrl pkgs.wmctrl pkgs.gnugrep pkgs.findutils]}"];
      ExecStart = "${stlc}/bin/stlc";
    };
    Unit = {
      Description = "Autoclose sublime text 'please buy licence' windows";
      After = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
