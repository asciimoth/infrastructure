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
  environment.systemPackages = with pkgs; [
    tree
    #b3sum
    #openssl
  ];

  #services.getty.autologinUser = "root";

  boot.initrd = {
    extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.bash}/bin/bash
      copy_bin_and_libs ${pkgs.tree}/bin/tree
      copy_bin_and_libs ${pkgs.gnupg}/bin/gpg2
    '';
    kernelModules = [
      "uas"
      "usbcore"
      "usb_storage"
      "vfat"
      "nls_cp437"
      "nls_iso8859_1"
    ];
    availableKernelModules = [
      # For better luks encryption performance
      "aesni_intel"
      "cryptd"
    ];
    # TODO Add hello message with my contacts
    postDeviceCommands = let
      path_hash = "50e97458df1ecadddd93c088873054dae35bedf51530e98df80d9c2ad814520a";
      content_hash = "f1ac885c1f27071f89ff728d627fa7859f86e6526d9fd1ebd164a48d60515db1";
    in
      lib.mkBefore ''
        echo "Initrd shell started"
        bash
      '';
    #luks.devices."crypted" = {
    #  keyFile = "/decrypt/decrypted_key";
    #  preLVM = lib.mkForce false;
    #};
  };
}
