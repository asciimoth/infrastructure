#!/bin/bash

# Function to remove duplicates from an array
remove_duplicates() {
    local -a unique_elements=()
    local -A seen=()  # associative array to track seen elements
    local element

    for element in "${@:2}"; do  # Skip the first argument (delimiter)
        if [[ "$element" != "" ]]; then
            if [[ -z ${seen[$element]} ]]; then
                unique_elements+=("$element")  # add unseen element to unique_elements
                seen[$element]=1  # mark element as seen
            fi
        fi
    done

    # Join array elements using the specified delimiter
    local IFS="$1"  # Set internal field separator to the delimiter
    echo -n "${unique_elements[*]}"
}

# Check the number of arguments
if [ "$#" -eq 0 ]; then
    exit 0  # Exit silently if no arguments are passed
elif [ "$#" -eq 1 ]; then
    echo -n "$1"  # If only one argument is passed, print it
    exit 0
fi

# Process the first argument to determine the delimiter
if [[ "$1" == "--newline" ]]; then
    delimiter=$'\n'
    shift
elif [[ "$1" =~ ^--delimiter=(.*) ]]; then
    delimiter="${BASH_REMATCH[1]}"
    shift
else
    delimiter=" "  # Default delimiter is a space
fi

# Pass the delimiter and the remaining arguments to remove_duplicates
remove_duplicates "$delimiter" "$@"
