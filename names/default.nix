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
