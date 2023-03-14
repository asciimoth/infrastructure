#!/bin/bash

function get_volume {
    amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1
}

function is_mute {
    amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null
}

function show {
    MSG="<b>Volume</b>"
    if is_mute ; then
        MSG="$MSG muted"
    else
        MSG="$MSG $(get_volume)"
    fi
    notify-by-name -n VOLUME_CHANGE -u normal -t 600 -b "$MSG" > /dev/null
}

function up {
    amixer -c 0 set Master on > /dev/null
    amixer -c 0 sset Master 5%+ > /dev/null
}

function down {
    amixer -c 0 set Master on > /dev/null
    amixer -c 0 sset Master 5%- > /dev/null
}

function mute {
    amixer -c 0 set Master 1+ toggle > /dev/null
}

case $1 in
    +)
        up
        ;;
    up)
        up
        ;;
    -)
        down
        ;;
    down)
        down
        ;;
    m)
        mute
        ;;
    mute)
        mute
        ;;
esac

show
