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
  my-ranger = pkgs.writeShellScriptBin "ranger" ''
    NIX_RANGER=/home/$USER/.config/ranger_nix
    REAL_RANGER=/home/$USER/.config/ranger
    LOCKSFILE=$REAL_RANGER/lockfile
    LOCKED_REV=$(read-or-value $LOCKSFILE "NONE")
    ACTUAL_REV=$(readlink -f $NIX_RANGER)
    if [ "$LOCKED_REV" != "$ACTUAL_REV" ]; then
      cp -rL $NIX_RANGER $REAL_RANGER
      chmod -R +w $REAL_RANGER
      echo -n "$ACTUAL_REV" > $LOCKSFILE
    fi
    #
    ${pkgs.ranger}/bin/ranger $@
  '';
  pick = pkgs.writeShellScriptBin "pick" ''
    TMPFILE="/tmp/pick-$(${pkgs.openssl}/bin/openssl rand 40 | base32)"
    CMD="$1=$TMPFILE"
    touch $TMPFILE
    controlbox ranger $CMD
    cat $TMPFILE
    rm -rf $TMPFILE
  '';
in {
  environment.systemPackages = with pkgs; [
    my-ranger #ranger
    imagemagick
    libarchive
    atool
    unrar
    p7zip
    exiftool
    mupdf
    poppler_utils
    transmission
    jq
    pandoc
    djvulibre
    ffmpegthumbnailer
    ffmpeg
    gnome-epub-thumbnailer
    calibre
    file
    #
    pick
  ];
  home-manager.users.${constants.MainUser} = {pkgs, ...}: {
    home.file.".config/ranger_nix".source = ./ranger;
  };
}
