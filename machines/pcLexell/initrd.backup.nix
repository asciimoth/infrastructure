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
    b3sum
    openssl
  ];

  #services.getty.autologinUser = "root";

  boot.initrd = {
    extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.bash}/bin/bash
      copy_bin_and_libs ${pkgs.b3sum}/bin/b3sum
      copy_bin_and_libs ${pkgs.util-linux}/bin/lsblk
      copy_bin_and_libs ${pkgs.tree}/bin/tree
      copy_bin_and_libs ${pkgs.openssl}/bin/openssl
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
        REF_PATH_HASH="${path_hash}"
        REF_CONTENT_HASH="${content_hash}"
        mkdir -p /key
        mkdir -p /decrypt
        echo "Waiting two seconds to make sure the USB key has been loaded"
        sleep 2
        echo "Geting list of FAT32 partitions on all disks"
        lsblk -f --raw | grep "vfat FAT32" | cut -f1 -d" " | while read partition
        do
          echo "Mount /dev/$partition to /key"
          mount -n -t vfat -o ro /dev/$partition /key
          echo "List files in /key"
          tree /key -fxainF -L 3 --prune --noreport | grep -v '/$' | grep -v '>' | tr -d '*' | while read file
          do
            HASH=$(echo $file | b3sum | cut -f1 -d" ")
            if [ "$REF_PATH_HASH" == "$HASH" ]; then
              echo "file found: $file"
              CONTENT_HASH=$(b3sum $file | cut -f1 -d" ")
              if [ "$CONTENT_HASH" == "$REF_CONTENT_HASH" ]; then
                echo "found key file: $file"
                cp $file /decrypt/encrypted_key
                return
              fi
            fi
          done
          echo "Unmount /key"
          umount /key
        done
        # Decrypt /decrypt/encrypted_key with openssl to /decrypt/decrypted_key
        clear
        read -sp "Enter password:" PASSWORD
        openssl enc -aes-256-cbc -d -pbkdf2 -in /decrypt/encrypted_key -out /decrypt/decrypted_key -k "$PASSWORD"
        #cat /decrypt/decrypted_key
        # Unlock luks partition with /decrypt/decrypted_key
        #bash
      '';
    luks.devices."crypted" = {
      keyFile = "/decrypt/decrypted_key";
      preLVM = lib.mkForce false;
    };
  };
}
