#!/bin/bash

echo "Servidor HMTP"

echo "(0) LISTEN - Levantando el servidor"

MSG=`nc -l 4242`
HANDSHAKE=`echo $MSG | cut -d " " -f 1`
IP_CLIENT=`echo $MSG | cut -d " " -f 2`

echo "(3) SEND - Confirmación Handshake"

if [ "$HANDSHAKE" != "GREEN_POWA" ]
	then
		echo "KO_HMTP" | nc $IP_CLIENT 4242
		exit 1
	fi

echo "OK_HMTP" | nc $IP_CLIENT 4242

MSG=`nc -l 4242`

exit 0
