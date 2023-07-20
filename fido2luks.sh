#!/usr/bin/env bash

# fido2luks.sh /dev/sda2 pcLexell ~/creds $PASSWORD <token fido pin> <new password>

export PARTITION=$1
export NEWHOSTNAME=$2
export CREDFILE=$3
export PASSWORD=$4
export DEVICEPIN=$5
export NEWPASS=$6

export FIDO2_LABEL="$PARTITION @ $NEWHOSTNAME"
export CRED=$(echo "$DEVICEPIN" | fido2luks credential "$FIDO2_LABEL" --pin --pin-source /dev/stdin)
echo $CRED >> $CREDFILE
echo $'\n' >> $CREDFILE
expect -c 'spawn fido2luks -i add-key $::env(PARTITION) $::env(CRED) --pin; expect "Authenticator PIN:"; send "$::env(DEVICEPIN)\r"; expect "Current password:"; send "$::env(PASSWORD)\r"; expect "Password to be added:"; send "$::env(NEWPASS)\r"; expect "Password to be added (again):"; send "$::env(NEWPASS)\r"; interact'
