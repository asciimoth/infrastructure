for FILE in /etc/chownd/*; do
    # Check if file owned by root and only root cat modify it
    LSL=$(ls -l $FILE)
    UNAME=$(echo "$LSL" | awk '{print $3}')
    WRITABLE=${LSL:5:1}${LSL:5:1}
    if [ "root" == "$UNAME" ]; then
        if [ "--" == "$WRITABLE" ]; then
            PTH=$(cat $FILE)
            CMD="chown -R $PTH"
            #echo "$CMD" > /etc/chownd.log
            $CMD
        fi
    fi
done
