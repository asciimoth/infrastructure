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
  notifybyname = pkgs.writeShellScriptBin "notify-by-name" (builtins.readFile ./notify-by-name.sh);
in {
  environment.systemPackages = with pkgs; [
    udisks2
    #udiskie
  ];
  services.udisks2 = {
    enable = true;
  };
  home-manager.users."${constants.MainUser}".systemd.user.services.udiskie = {
    Service = {
      Environment = ["PATH=${lib.makeBinPath [pkgs.udiskie pkgs.notify-desktop pkgs.coreutils-full notifybyname]}"];
      ExecStart = toString (pkgs.writeShellScript "yubikey-touch-detector" ''
        udiskie -NaT --notify-command "notify-by-name -n UDISKIE_EVENT -u normal -t 800 -b 'USB'"
      '');
    };
    Unit = {
      Description = "Udiskie USB manager";
      After = ["graphical-session.target"];
      Wants = ["gpg-agent-ssh.socket" "gpg-agent.socket"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
