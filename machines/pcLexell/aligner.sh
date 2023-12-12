#!/usr/bin/env bash

calculate_length() {
    local length=0
    while IFS= read -r line; do
        local line_length=${#line}
        length=$([ "$length" -gt "$line_length" ] && echo $length || echo $line_length)
    done <<< "$1"
    echo "$length"
}

print_margin() {
    for i in $( seq 0 $1 ); do
        echo -n " "
    done
}

print_center(){
    local x
    local y
    local TXT="$1"
    local LENGTH=$(OR "echo $3" "echo ${#TXT}")
    case "$2" in
        "left" ) x=0;;
        "right" ) x=$(( ($(tput cols) - $LENGTH - 1)));;
        * ) x=$(( ($(tput cols) - $LENGTH) / 2));;
    esac
    for i in $( seq 0 $x ); do
        echo -n " "
    done
    echo -n "$TXT"
}

print_center_multiline(){
    while IFS= read -r line; do
        print_center "$line" "$2" "$3"
        echo ""
    done <<< "$1"
}

ALIGN="center"
BLOCK=false
TRIM=false
TEXT=""

while true; do
    case "$1" in
        "-c" | "--center" ) ALIGN="center"; shift ;;
        "-l" | "--left" )   ALIGN="left";   shift ;;
        "-r" | "--right" )  ALIGN="right";  shift ;;
        "-b" | "--block" )  BLOCK=true;     shift ;;
        "-t" | "--trim" )   TRIM=true;      shift ;;
        -- )                shift;          break ;;
        * )                 TEXT="$1";      break ;;
    esac
done

if [ "$TEXT" == "" ]; then
    TEXT=$(</dev/stdin)
fi

LENGTH=""

if $BLOCK; then
    decolored=$(echo "$TEXT" | sed -r "s/\x1B\[[0-9;]*[JKmsu]//g")
    LENGTH=$(calculate_length "$decolored")
fi

print_center_multiline "$TEXT" "$ALIGN" "$LENGTH"
