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
  #pass otp append github.com --secret --issuer GitHub
  mypass = with pkgs; pass.withExtensions (ext: [ext.pass-otp]);
in {
  # Fix some GUI pinentry issues
  services.dbus.packages = [pkgs.gcr];

  environment.systemPackages = with pkgs; [
    pinentry-qt
    rofi-pass
    mypass
    #pass.withExtensions (exts: [ exts.pass-otp ])
  ];

  #services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };

  home-manager.users."${constants.MainUser}" = {pkgs, ...}: {
    programs.gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
      publicKeys = [
        {
          source = ../../keys/moth.pub.gpg;
          trust = 5;
        }
      ];
    };
  };
}
