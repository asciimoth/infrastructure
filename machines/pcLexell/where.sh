#!/usr/bin/env bash

nope() {
    echo "$1"
}

nsh() {
    local input="$1"
    local base_pattern="/nix/store/"
    
    # Check if the input starts with "/nix/store/"
    if [[ $input == $base_pattern* ]]; then
        # Extract the part after "/nix/store/" and before the first "-"
        local base64_part=${input#$base_pattern}
        base64_part=${base64_part%%-*}

        # Replace the base64 part with "s" and output the result
        echo "${input/$base_pattern$base64_part-//n/s/}"
    else
        # If the input does not start with "/nix/store/", return it as is
        echo "$input"
    fi
}

npk() {
    local input_str="$1"
    # Remove the prefix up to and including the first '-'
    local without_prefix=${input_str#*-}
    # Extract everything before the first '/'
    local extracted_text=${without_prefix%%/*}
    if [[ "$extracted_text" == "system-path" ]]; then
        echo ""
    else
        echo "$extracted_text"
    fi
}


NPR=
NLN=
SLN=

MODE=nope

# Counter for detecting usage of mutually exclusive options
NSH_NPK_NNM=0

# Loop through all the arguments
CMD=(whereis)
for arg in "$@"
do
    # Check if the argument is -h or --help
    if [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]]; then
        whereis_help=$(whereis --help)
        echo "$whereis_help"
        echo
        echo "Extra options:"
        echo " --npr trim prefix"
        echo " --nln write each path at new line"
        echo " --sln write all in single line"
        echo
        echo " --nsh use short format for /nix/store paths"
        echo " --npk show only pkg name for /nix/store paths"
        exit 0
    elif [[ "$arg" == "--npr" ]]; then
        NPR=1
    elif [[ "$arg" == "--nln" ]]; then
        NLN=1
    elif [[ "$arg" == "--sln" ]]; then
        SLN=1
    elif [[ "$arg" == "--nsh" ]]; then
        MODE=nsh
        ((NSH_NPK_NNM++))
    elif [[ "$arg" == "--npk" ]]; then
        MODE=npk
        ((NSH_NPK_NNM++))
    else
        CMD+=("$arg")
    fi
done

if [[ $NLN ]] && [[ $SLN ]]; then
    echo "You can use only one of this options: --nln --sln"
    echo "See --help"
    exit 1
fi

if (( NSH_NPK_NNM > 1 )); then
    echo "You can use only one of this options: --nsh --npk"
    echo "See --help"
    exit 1
fi

RAW_OUTPUT=$("${CMD[@]}")
while read -r line; do
    IFS=' ' read -r -a SUBSTRINGS <<< "$line"
    [[ $NPR ]] || echo -n "${SUBSTRINGS[0]} "
    unset SUBSTRINGS[0]
    RESULT=()
    for element in "${SUBSTRINGS[@]}"; do
        RESULT+=("$($MODE "$element")")
        if [[ -L "$element" ]]; then
            result="$($MODE $(readlink "$element"))"
            if [[ "$result" != "" ]]; then
                RESULT+=("$result")
            fi
        fi
    done
    if [[ $NLN ]]; then
        arraydedup --newline "${RESULT[@]}"
        echo
    elif [[ $SLN ]]; then
        arraydedup "${RESULT[@]}"
        echo -n " "
    else
        arraydedup "${RESULT[@]}"
        echo
    fi
done <<< "$RAW_OUTPUT"
