{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  # perl -nle 'print if m{^[[:ascii:]]+$}' names/Minerals | awk '{$1=$1};1' | cut -d ' ' -f1 | cut -d '-' -f1 | uniq -i > names/Minerals.txt
  nnormalise = pkgs.writeShellScriptBin "nnormalise" ''
    tree $1 -fxainF -L 3 --prune --noreport | grep -v '/$' | grep -v '>' | tr -d '*'
  '';
in {
  environment.etc.naming.source = ./names;
  environment.systemPackages = with pkgs; [
    tree
    
    nnormalise
  ];
}
