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
  boot.initrd = {
    postDeviceCommands = let
      encrypted_key_b64 = (builtins.readFile ./encrypted_key.b64);
      gpg_key_b64 = (builtins.readFile ../../keys/moth.pub.b64);
    in
      lib.mkBefore ''
        echo "${encrypted_key_b64}" | base64 -d > encrypted_key
        echo "${gpg_key_b64}" | base64 -d > gpg_key
      '';
    luks.devices."crypted" = {
      preLVM = lib.mkForce false;
      gpgCard = {
        encryptedPass = "/encrypted_key";
        publicKey = "/gpg_key";
      };
    };
  };
}
