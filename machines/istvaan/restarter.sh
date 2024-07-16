#!/usr/bin/env bash
set -o noclobber -o noglob -o nounset -o pipefail

# Generate random tmp dir and filename
tmpdir=$(mktemp -d -p /tmp)
chmod 777 "$tmpdir"
tmpfile=$(mktemp "$tmpdir/XXXXXX")

# Save previous value of $RESTARTER_FILE
old_restarter_file="${RESTARTER_FILE:-}"

# Set new one
export RESTARTER_FILE="$tmpfile"

# Function to clean up before exiting
cleanup() {
  export RESTARTER_FILE="$old_restarter_file"
  rm -rf "$tmpdir" 2>/dev/null || true
}

# Ensure cleanup is called on script exit
trap cleanup EXIT

echo "Starting $@"

# Main loop
while true; do
  # Delete $RESTARTER_FILE if exists
  [ -f "$RESTARTER_FILE" ] && rm -f "$RESTARTER_FILE"
  # Run shell command constructed from args
  "$@"
  # Break the loop if $RESTARTER_FILE does not exist
  [ ! -f "$RESTARTER_FILE" ] && break
  echo "Restarting $@"
done

# Cleanup will be called automatically due to trap
