#!/usr/bin/env bash

# fido2luks.sh /dev/sda2 pcLexell ~/creds $PASSWORD

export PARTITION=$1
export NEWHOSTNAME=$2
export CREDFILE=$3
export PASSWORD=$4

export FIDO2_LABEL="$PARTITION @ $NEWHOSTNAME"
export CRED=$(fido2luks credential "$FIDO2_LABEL")
echo $CRED >> $CREDFILE
echo $'\n' >> $CREDFILE
expect -c 'spawn fido2luks -i add-key $::env(PARTITION) $::env(CRED) ; expect "Current password:"; send "$::env(PASSWORD)\r"; interact'
