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
  nixlogo = pkgs.writeText "NixOsLogo" (builtins.readFile ./nix_logo);
  notifybyname =
    pkgs.writeShellScriptBin "notify-by-name"
    (builtins.readFile ./notify-by-name.sh);
  aligner = pkgs.writeShellScriptBin "aligner" (builtins.readFile ./aligner.sh);
  loginer = pkgs.writeShellScriptBin "loginer" (builtins.readFile ./loginer.sh);
  volume = pkgs.writeShellScriptBin "volume" (builtins.readFile ./volume.sh);
  bright = pkgs.writeShellScriptBin "bright" (builtins.readFile ./bright.sh);
  printlogo = pkgs.writeShellScriptBin "printlogo" ''
    cat ${nixlogo} | aligner -b $@
  '';
  where = pkgs.writeShellScriptBin "where" ''
    #!/usr/bin/env bash
    for ENTRY in "$@"
    do
        RAW=$(whereis $ENTRY)
        IFS=' ' read -r NAME RAW <<< "$RAW"
        echo -n "$NAME "
        for PTH in $RAW; do
            #echo "$PTH"
            if [ -d "$PTH" ]; then
                echo -n "$PTH ";
            else
                if [[ -x "$PTH" ]]
                then
                    echo -n "$PTH "
                    PTH=$(readlink -f "$PTH")
                    echo -n "$PTH "
                else
                    echo -n "$PTH "
                fi
            fi
        done
        echo ""
    done
  '';
  uclip = pkgs.writeShellScriptBin "uclip" ''
    # Universal text clipboard manager
    # for both X11 and wayland
    if (( $# == 0 )) ; then
        TEXT=$(</dev/stdin)
    else
        TEXT="$1"
    fi
    echo -n "$TEXT" | ${pkgs.xclip}/bin/xclip -selection primary &>/dev/null
    echo -n "$TEXT" | ${pkgs.xclip}/bin/xclip -selection secondary &>/dev/null
    echo -n "$TEXT" | ${pkgs.xclip}/bin/xclip -selection clipboard &>/dev/null
    echo -n "$TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy &>/dev/null
  '';
  file2clip = pkgs.writeShellScriptBin "file2clip" ''
    FILE=$1
    MIME=$(${pkgs.file}/bin/file -b --mime-type "''${FILE}")
    if [[ "$MIME" != "image"* ]]; then
      MIME="text/plain"
    fi
    cat "''${FILE}" | xclip -selection primary -t "$MIME"
    cat "''${FILE}" | xclip -selection secondary -t "$MIME"
    cat "''${FILE}" | xclip -selection clipboard -t "$MIME"
  '';
  bashscript = pkgs.writeShellScriptBin "bashscript" ''
    echo "#!/usr/bin/env bash" > $1
    chmod +x $1
    echo $1
  '';
  decolor = pkgs.writeShellScriptBin "decolor" ''
    cat /dev/stdin | sed -r "s/\x1B\[[0-9;]*[JKmsu]//g"
    #
  '';
  randqr = pkgs.writeShellScriptBin "randqr" ''
    while true; do
      clear
      openssl rand 32 | qrencode -t UTF8 -o -
      sleep 0.1
    done
  '';
  ors = pkgs.writeShellScriptBin "OR" ''
    # Return output of first command with non empty stdout
    # Usage:
    # OR COMMAND1 COMMAND2 COMMANDN
    for ___CMD in "$@"
    do
        RESULT=$(eval $___CMD)
        if [ -n "$RESULT" ]; then
            echo "$RESULT"
            exit 0
        fi
    done
  '';
  read-or-value = pkgs.writeShellScriptBin "read-or-value" ''
    RET=$(cat $1 2> /dev/null)
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        RET=$2
    fi
    echo "$RET"
  '';
  num-max = pkgs.writeShellScriptBin "num-max" ''
    [ "$1" -gt "$2" ] && echo $1 || echo $2
  '';
  num-min = pkgs.writeShellScriptBin "num-min" ''
    [ "$1" -gt "$2" ] && echo $2 || echo $1
  '';
  num-lim = pkgs.writeShellScriptBin "num-lim" ''
    num-min $(num-max $1 $3) $2
  '';
  percent-to-dec = pkgs.writeShellScriptBin "percent-to-dec" ''
    awk "BEGIN { x = $1; print (x / 100) }"
  '';
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
  myexa = pkgs.writeShellScriptBin "exa" ''
    ${pkgs.eza}/bin/eza ''${@: 2}
  '';
in {
  users.defaultUserShell = pkgs.fish;

  environment.shellAliases = {
    # Nix/NixOS aliases
    nswitch = "sudo nixos-rebuild switch --flake /etc/infrastructure";
    ncollect = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
    noptimise = "sudo nix-store --optimise";
    nfmt = "alejandra";

    #"${config.options.ABC}" = "echo ABC";

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
    ll = "${myexa}/bin/exa --oneline -L -T -F --group-directories-first -l --icons";
    la = "${myexa}/bin/exa --oneline -L -T -F --group-directories-first -la --icons";
    l = "${myexa}/bin/exa --oneline -L -T -F --group-directories-first --icons";

    # Etc
    bat = "bat --paging never";
    tre = "${myexa}/bin/exa --oneline -T -F --group-directories-first -a --icons";
    gtr = "${myexa}/bin/exa --oneline -T -F --group-directories-first -a --git-ignore --ignore-glob .git --icons";
    print = "figlet -c -t";
    stop = "sudo shutdown now";
    copy = "xclip -selection c";
    random64 = "openssl rand -base64 33";
    randomhex = "openssl rand -hex 20";
    genpass = "openssl rand -base64 33";
    cppass = "openssl rand -base64 33 | xclip -selection c";
    pause = "sleep 100000d";
    sstat = "systemctl status";
    jour = "journalctl -u";
    sec = "systemd-analyse security";
    size = "du -shP";
    root = "sudo -i";
    mke = "chmod +x";
    dropproxy = ''export ALL_PROXY="" && export all_proxy="" && export SOCKS_PROXY = "" && export socks_proxy = "" && export HTTP_PROXY = "" && export http_proxy = "" && export HTTPS_PROXY = "" && export https_proxy = ""'';
    fkill = "ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -9";
  };

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./init.fish;
  };

  security.sudo.enable = true;

  services.getty.autologinUser = "moth";

  environment.variables = {HISTCONTROL = "ignoreboth:erasedups";};

  environment.systemPackages = with pkgs; [
    # Shell tools
    #exa # Modern analog of ls/tree
    bat # Modern analog of cat
    ripgrep # Modern analog of grep with some usefull patches
    ripgrep-all # Some usefull extensions for ripgrep
    #qrencode # Generate & print qr codes in terminal
    figlet # Print text with ascii fonts
    xclip # x11 clipboard managment tool
    fzf # Fuzzy search

    # My scripts
    num-max
    num-min
    num-lim
    ors
    read-or-value
    withdir
    clone-commit
    drop-caches
    percent-to-dec
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
    notifybyname
    volume
    bright
    decolor
    randqr
    uclip
    file2clip
    where
    bashscript
    loginer
    aligner
    printlogo
    myexa
  ];
}
