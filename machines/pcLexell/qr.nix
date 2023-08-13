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
  scanqr = pkgs.writeShellScriptBin "scanqr" ''
    TMPDIR="/tmp/scanqr-$USER"
    mkdir -p $TMPDIR
    chmod 700 $TMPDIR
    TMPFILE="$TMPDIR/$(openssl rand -hex 30)"
    flameshot gui -r > $TMPFILE
    zbarimg -q --raw $TMPFILE
    rm -rf $TMPFILE
  '';
in {
  environment.systemPackages = with pkgs; [
    zbar
    qrencode
    scanqr
    openssl
  ];
  environment.shellAliases = {
    qr = "qrencode -t UTF8 -o -";
    passqr = "scanqr | pass otp append"
  };
}
