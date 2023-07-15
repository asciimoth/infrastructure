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
  ...
}: let
  constants = import ./constants.nix;
in {
  services.udev.packages = [ pkgs.yubikey-personalization ];

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
    yubikey-touch-detector
  ];
  home-manager.users."${constants.MainUser}".systemd.user.services.yubikey-touch-detector = {
    Service = {
      Environment = [ "PATH=${lib.makeBinPath [ pkgs.gnupg pkgs.yubikey-touch-detector ]}" ];
      ExecStart = toString (pkgs.writeShellScript "yubikey-touch-detector" ''
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        yubikey-touch-detector -libnotify
      '');
    };
    Unit = {
      Description = "yubikey-touch-detector";
      After = [ "graphical-session.target" ];
      Wants = [ "gpg-agent-ssh.socket" "gpg-agent.socket" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
