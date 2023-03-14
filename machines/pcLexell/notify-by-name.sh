#!/bin/bash

function call {
    NAME=$1
    COMMAND=$2
    SUMMARY=$3
    BODY=$4
    FILENAME="/tmp/notify-name-$USER-$NAME"
    if test -f "$FILENAME"; then
        IDENT=$(cat $FILENAME)
        if test -z "$SUMMARY" ; then
            $COMMAND -r $IDENT "$BODY"
        else
            $COMMAND -r $IDENT "$SUMMARY" "$BODY"
        fi
    else 
        if test -z "$SUMMARY" ; then
            IDENT=$($COMMAND "$BODY")
        else
            IDENT=$($COMMAND "$SUMMARY" "$BODY")
        fi
        echo $IDENT > $FILENAME
    fi
}

NAME="__DEFAULT_NOTIFICATION_NAME__"
COMMAND="notify-desktop"
SUMMARY=""
BODY=""

while getopts 'n:u:t:a:i:c:s:b:h' opt; do
  case "$opt" in
    n)
      NAME=$OPTARG
      ;;
    s)
      SUMMARY="$OPTARG"
      ;;
    b)
      BODY="$OPTARG"
      ;;
    u)
      COMMAND="$COMMAND -u $OPTARG"
      ;;
    t)
      COMMAND="$COMMAND -t $OPTARG"
      ;;
    a)
      COMMAND="$COMMAND -a $OPTARG"
      ;;
    i)
      COMMAND="$COMMAND -i $OPTARG"
      ;;
    c)
      COMMAND="$COMMAND -c $OPTARG"
      ;;
    ?|h)
      echo "Usage: $(basename $0) [-nutaicsm arg] [-h] <SUMMARY> [BODY]"
      echo ""
      echo "Send notification like notify-desktop but with text id"
      echo ""
      echo "  -n Name"
      echo "  -u Urgency"
      echo "  -t Expire time"
      echo "  -a App name"
      echo "  -i Icon"
      echo "  -c Category"
      echo "  -s Summary"
      echo "  -b Body"
      echo "Also help of notify-desktop:"
      notify-desktop --help
      exit 0
      ;;
  esac
done
shift "$(($OPTIND -1))"

call "$NAME" "$COMMAND" "$SUMMARY" "$BODY"
