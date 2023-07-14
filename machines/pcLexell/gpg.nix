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
}: {
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Fix some GUI pinentry issues
  services.dbus.packages = [ pkgs.gcr ];

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
    pinentry-qt
  ];

  #services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };
}
