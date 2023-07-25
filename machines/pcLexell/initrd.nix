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
  boot.initrd.luks = {
    gpgSupport = true;
    devices."crypted" = {
      gpgCard = {
        encryptedPass = "./luks_key.asc";
        publicKey = "../../keys/moth.pub.asc";
      };
    };
  };
}
