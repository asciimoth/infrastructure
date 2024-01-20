#!/usr/bin/env bash
set -o noclobber -o noglob -o nounset -o pipefail

# Autoclose sublime text "please buy licence" windows

if [[ "$0" != "" ]]; then
    echo "Wait $1 secs"
    sleep $1
    echo "Started!"
fi

read -r -d '' PATTERN << EOM
_NET_WM_NAME(UTF8_STRING) =
_NET_WM_STATE(ATOM) = _NET_WM_STATE_MODAL, _NET_WM_STATE_SKIP_TASKBAR
_NET_WM_WINDOW_TYPE(ATOM) = _NET_WM_WINDOW_TYPE_DIALOG
WM_CLASS(STRING) = "sublime_text", "Sublime_text"
WM_NAME(STRING) =
EOM
# Normalize
PATTERN=$(echo $PATTERN | xargs)

PREVIOUS_WINDOWS=()

xprop -spy -root _NET_CLIENT_LIST | while read WINDOWS; do
    WINDOWS=($(echo $WINDOWS | grep -o '0x[0-9a-f]\+'))
    # Find elements in WINDOWS not in PREVIOUS_WINDOWS
    NEW_WINDOWS=()
    for i in "${WINDOWS[@]}"; do
        is_old=
        for j in "${PREVIOUS_WINDOWS[@]}"; do
            [[ "$i" == "$j" ]] && { is_old="true"; break; }
        done
        [[ -n $is_old ]] || NEW_WINDOWS+=("$i")
    done
    PREVIOUS_WINDOWS=("${WINDOWS[@]}")
    # run check for each window
    for new_window in "${NEW_WINDOWS[@]}"; do
        # Get info
        info=$(xprop -id $new_window _NET_WM_NAME _NET_WM_STATE _NET_WM_WINDOW_TYPE WM_CLASS WM_NAME)
        # Normalize
        info=$(echo $info | xargs)
        if [[ "$info" == "$PATTERN" ]]; then
            echo "MATCHED: $info"
            # Kill
            wmctrl -i -c $new_window
        fi
    done
done
