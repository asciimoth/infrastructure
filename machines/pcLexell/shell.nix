{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  printfiles = pkgs.writeShellScriptBin "printfiles" ''
  if [ -d "$1" ] ; then
    tree $1 -fxainF -L 3 --prune --noreport | grep -v '/$' | grep -v '>' | tr -d '*'
  else
     echo $1
  fi
  '';
  getscript = pkgs.writeShellScriptBin "getscript" ''
    INPUT=$1
    OUTPUT=$INPUT
    if [[ ! -z "$2" ]];
    then
      OUTPUT=$2
    fi
    cat $(whereis -b $INPUT | cut -d ' ' -f 2) > $OUTPUT
    chmod +x $OUTPUT
  '';
  withdir = pkgs.writeShellScriptBin "withdir" ''
    pth=$(pwd)
    cd $1
    ''${@: 2}
    cd $pth
    # There is cursed bug in syntax higliting in some editors
    # So we need to add this trash rows to make higliting working correctly
    exit
    ''${@: 2}
  '';
  clone-commit = pkgs.writeShellScriptBin "clone-commit" ''
    postf=".git"
    URI=$1
    COMMIT=$2
    NAME=$(basename $URI)
    NAME="''${NAME%$postf}"
    if [ $3 ];
    then
      NAME=$3
    fi
    mkdir $NAME
    cd $NAME
    git init
    git remote add origin $URI
    git fetch --depth 1 origin $COMMIT
    git checkout FETCH_HEAD
    exit
    \"
    exit
    ''${}
  '';
  drop-caches = pkgs.writeShellScriptBin "drop-caches" ''
    sync; echo 3 > /proc/sys/vm/drop_caches
  '';
  dup = pkgs.writeShellScriptBin "dup" ''
    i=1
    while [[ $i -le $1 ]]
    do
      ''${@: 2}
      ((i = i + 1))
    done
    exit
    ''${@: 2}
  '';
  x2 = pkgs.writeShellScriptBin "x2" "dup 2 \${@: 1}";
  x3 = pkgs.writeShellScriptBin "x3" "dup 3 \${@: 1}";
  x4 = pkgs.writeShellScriptBin "x4" "dup 4 \${@: 1}";
  x5 = pkgs.writeShellScriptBin "x5" "dup 5 \${@: 1}";
  x6 = pkgs.writeShellScriptBin "x6" "dup 6 \${@: 1}";
  x7 = pkgs.writeShellScriptBin "x7" "dup 7 \${@: 1}";
  x8 = pkgs.writeShellScriptBin "x8" "dup 8 \${@: 1}";
  x9 = pkgs.writeShellScriptBin "x9" "dup 9 \${@: 1}";
  x10 = pkgs.writeShellScriptBin "x10" "dup 10 \${@: 1}";
  printscript = pkgs.writeShellScriptBin "printscript" ''
    bat $(whereis -b $1 | cut -d ' ' -f 2) -p
  '';
in {
  users.defaultUserShell = pkgs.fish;

  environment.shellAliases = {
    # Nix/NixOS aliases
    nswitch = "sudo nixos-rebuild switch --flake /etc/infrastructure";
    ncollect = "sudo nix-collect-garbage -d";
    noptimise = "sudo nix-store --optimise";
    nfmt = "alejandra";

    # Navigation
    ch = "cd ~";
    ".." = "cd ..";
    "..." = "cd ../..";
    ".3" = "cd ../../..";
    "...." = "cd ../../..";
    ".4" = "cd ../../../..";
    "....." = "cd ../../../..";
    ".5" = "cd ../../../../..";
    "......" = "cd ../../../../..";

    # Pings
    p1 = "ping 1.1.1.1";
    p8 = "ping 8.8.8.8";

    # Abbreviations
    e = "exit";
    c = "clear";
    h = "history | rg";
    rf = "rm -rf";
    ll = "exa --oneline -L -T -F --group-directories-first -l";
    la = "exa --oneline -L -T -F --group-directories-first -la";
    l = "exa --oneline -L -T -F --group-directories-first";

    # Etc
    tr = "exa --oneline -T -F --group-directories-first -a";
    gtr = "exa --oneline -T -F --group-directories-first -a --git-ignore --ignore-glob .git";
    qr = "qrencode -t UTF8 -o -";
    print = "figlet -c -t";
    stop = "shutdown now";
    copy = "xclip -selection c";
    random64 = "openssl rand -base64 33";
    randomhex = "openssl rand -hex 20";
    genpass = "openssl rand -base64 33";
    cppass = "openssl rand -base64 33 | xclip -selection c";
    pause = "sleep 100000d";
    stat = "systemctl status";
    jour = "journalctl -u";
    sec = "systemd-analyse security";
    size = "du -shP";
    root = "sudo -i";
    mke = "chmod +x";
    dropproxy = ''export ALL_PROXY="" && export all_proxy="" && export SOCKS_PROXY = "" && export socks_proxy = "" && export HTTP_PROXY = "" && export http_proxy = "" && export HTTPS_PROXY = "" && export https_proxy = ""'';
  };

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./init.fish;
  };

  security.sudo.enable = true;

  services.getty.autologinUser = "moth";

  environment.variables = {
    HISTCONTROL = "ignoreboth";
  };

  environment.systemPackages = with pkgs; [
    # Shell tools
    exa # Modern analog of ls/tree
    bat # Modern analog of cat
    ripgrep # Modern analog of grep with some usefull patches
    ripgrep-all # Some usefull extensions for ripgrep
    qrencode # Generate & print qr codes in terminal
    figlet # Print text with ascii fonts
    xclip # x11 clipboard managment tool

    # My scripts
    withdir
    clone-commit
    drop-caches
    dup
    printscript
    x2
    x3
    x4
    x5
    x6
    x7
    x8
    x9
    x10
    getscript
    printfiles
  ];
}
