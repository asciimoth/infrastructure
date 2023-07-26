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
  normalisenamesfile = pkgs.writeShellScriptBin "normalisenamesfile" ''
    perl -nle 'print if m{^[[:ascii:]]+$}' $1 | awk '{$1=$1};1' | cut -d ' ' -f1 | cut -d '-' -f1 | uniq -i
  '';
  nnormalise = pkgs.writeShellScriptBin "nnormalise" ''
    printfiles $1 | while read file
    do
      #echo "<$file>"
      OUTPUT=$(normalisenamesfile $file)
      echo "$OUTPUT" > $file
    done
  '';
in {
  environment.etc.naming.source = ./names;
  environment.systemPackages = with pkgs; [
    tree
    perl

    normalisenamesfile
    nnormalise
  ];
}
