#!/bin/bash

CONFIG=".config/bright"

show () {
    MSG="<b>Light</b> $1"
    notify-by-name -n LIGHT_CHANGE -u normal -t 600 -b "$MSG" > /dev/null
}

set_back () {
    light -S "$1"
}

set_dim () {
    BRIGHT=$(percent-to-dec $1)
    OUTPUTS=$(xrandr | sed 1d | cut -d ' ' -f 1)
    while IFS= read -r OUTPUT; do
        if [ -z "$OUTPUT" ]
        then
            continue
        fi
        xrandr --output "$OUTPUT" --brightness "$BRIGHT"
    done <<< "$OUTPUTS"
}

set_all () {
    set_back $1
    set_dim $1
    echo "$1" > $CONFIG
}

set_show () {
    set_all $1
    show $1
}


VALUE=$(read-or-value $CONFIG "100")


if [ -z "$1" ]
then
    set_all $VALUE
else
    DELTA=$2
    if [ -z "$DELTA" ]
    then
        DELTA="10"
    fi
    case $1 in
        +)
            set_show $(num-lim 1 100 $(($VALUE + $DELTA)))
            ;;
        up)
            set_show $(num-lim 1 100 $(($VALUE + $DELTA)))
            ;;
        -)
            set_show $(num-lim 1 100 $(($VALUE - $DELTA)))
            ;;
        down)
            set_show $(num-lim 1 100 $(($VALUE - $DELTA)))
            ;;
    esac
fi
