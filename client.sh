#!/bin/bash

echo "Cliente HMTP"

echo "(1) SEND - Enviando el Handshake"

echo "GREEN_POWA 127.0.0.1" | nc localhost 4242

echo "(2) LISTEN - Escuchando confirmación"

MSG=`nc -l 4242`

echo $MSG

if [ "$MSG" != "OK_HMTP" ]
	then 
		echo "ERROR 1: Handshake mal formado"
		exit
	fi

echo "SEGUIMOS"
