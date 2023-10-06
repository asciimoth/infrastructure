#!/usr/bin/env bash

set -o noclobber -o noglob -o pipefail

CONFIG_PATH="$HOME/.config/loginer"
CACHE_PATH="$HOME/.cache/loginer"

root() {
    sudo -i
}

while true; do
LIST=""

while read -r cmd; do
    if [ "root" == "$cmd" ]; then
        continue
    fi
    CMD="$CONFIG_PATH/$cmd"
    # Check if $CMD owned by $USER or root
    if [ "$USER" != "$(stat -c '%U' $CMD)" ]; then
        if [ "root" != "$(stat -c '%U' $CMD)" ]; then
            continue
        fi
    fi
    # Check if $CMD writable only by owner
    PERM=$(stat -c "%A" $CMD)
    PERM="${PERM: 2:1}${PERM: 5:1}${PERM: 8:1}"
    if [ "w--" != "$PERM" ]; then
        continue
    fi
    # Check if $CMD executable
    if ! [ -x "$CMD" ]; then
        continue
    fi
    # Append
    if [ "" != "$LIST" ]; then
        LIST="$LIST"$'\n'
    fi
    LIST="$LIST$cmd"
done < <( ls $CONFIG_PATH )

LIST="$LIST"$'\nroot'

# Get cahed value
CACHED=$(cat $CACHE_PATH 2> /dev/null)
STATUS=$?
if [ $STATUS -ne 0 ]; then
    LINE="1"
else
    LINE=$(echo "$LIST" | grep -n "$CACHED" | cut -d: -f1)
    if [ "" == "$LINE" ]; then
        LINE="1"
    fi
fi

CMD=$(echo "$LIST" | fzf --bind "load:pos:$LINE" --layout=reverse --inline-info --border)

if [ "" != "$CMD" ]; then
    rm -rf $CACHE_PATH
    echo $CMD > $CACHE_PATH
fi

if [ "" == "$CMD" ]; then
    exit 0
fi

if [ "root" != "$CMD" ]; then
    CMD="$CONFIG_PATH/$CMD"
fi

$CMD
done
