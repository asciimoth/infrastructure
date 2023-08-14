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
  passshow = pkgs.writeShellScriptBin "passshow" ''
    STORE="/home/$USER/.password-store/"
    NAME=$((cd $STORE && find . -type f) | sed '/^.\/secret_service/d' | sed 's/^.\{2\}//' | sed 's/.\{4\}$//' | ${pkgs.fzf}/bin/fzf)
    CONTENT=$(cd $STORE && pass show $NAME)
    while true; do
      SELECTED=$(echo -n "$CONTENT" | fzf)
      if [ -n "$SELECTED" ]; then
        clear
        echo "$SELECTED"
        echo "copyed to clipboard"
        SELECTED=$(echo -n "$SELECTED" | sed "s/^[[:alnum:]]*: //")
        echo -n "$SELECTED" | qrencode -t UTF8 -o -
        echo -n "$SELECTED" | uclip
        read -n1 -s
      else
        clear
        exit 0
      fi
    done
  '';
  clipqr = pkgs.writeShellScriptBin "clipqr" ''
    DATA=$(scanqr)
    echo -n "$DATA" | uclip
    echo -n "$DATA"
  '';
  clipqr-desktop = pkgs.makeDesktopItem {
    name = "clipqr";
    desktopName = "clipqr";
    exec = "clipqr";
    terminal = false;
  };
  passshow-desktop = pkgs.makeDesktopItem {
    name = "passshow";
    desktopName = "passshow";
    exec = "passshow";
    terminal = true;
  };
in {
  environment.systemPackages = with pkgs; [
    zbar
    qrencode
    openssl
    #
    scanqr
    passshow
    clipqr
    #
    clipqr-desktop
    passshow-desktop
  ];
  environment.shellAliases = {
    qr = "qrencode -t UTF8 -o -";
    passqr = "scanqr | pass otp append web";
  };
}
