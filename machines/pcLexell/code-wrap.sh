#!/usr/bin/env bash
set -o noclobber -o noglob -o nounset -o pipefail

WORKING_DIR=$1

cd $WORKING_DIR

# TODO Add direnv loading support

COMMAND=""

while true; do
    if [[ "$COMMAND" == "" ]]; then
        COMMAND="restart"
    else
        COMMAND=$(echo -e "restart\nexit\nshell" | rofi -dmenu -mesg aaaa -p bbbbbb -i -no-custom)
    fi
    if [[ "$COMMAND" == "exit" ]]; then
        exit 0
    fi
    if [[ "$COMMAND" == "shell" ]]; then
        export NODIRENV=true
        wezterm start --no-auto-connect --always-new-process --cwd $PWD
        export NODIRENV=""
    else
        codium -wn ./
    fi
done
