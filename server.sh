#!/bin/bash

PORT="4242"

	echo "Servidor HMTP"

	echo "(0) LISTEN - Levantando el servidor"

MSG=`nc -l $PORT`

HANDSHAKE=`echo $MSG | cut -d " " -f 1`
IP_CLIENT=`echo $MSG | cut -d " " -f 2`

	echo "(3) SEND - Confirmación Handshake"

	if [ "$HANDSHAKE" != "GREEN_POWA" ]
		then
			echo "KO_HMTP" | nc $IP_CLIENT $PORT
			exit 1
		fi

	echo "OK_HMTP" | nc $IP_CLIENT $PORT

	echo "(4) LISTEN - Escuchando el nombre de archivo"

MSG=`nc -l $PORT`

PREFIX=`echo $MSG | cut -d " " -f 1`
FILE_NAME=`echo $MSG | cut -d " " -f 2`
FILE_MD5=`echo $MSG | cut -d " " -f 3`

	echo "(7) SEND - Confirmación nombre de archivo"

	if [ "$PREFIX" != "FILE_NAME" ]
		then
			echo "KO_FILE_NAME" | nc $IP_CLIENT $PORT
			exit 2
	fi

MD5SUM=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

	if [ "$MD5SUM" != "$FILE_MD5" ]
		then
			echo "KO_FILE_MD5" | nc $IP_CLIENT $PORT
			exit 3
	fi

	echo "OK_FILE_NAME" | nc $IP_CLIENT $PORT

	echo "(8) LISTEN - Escuchando datos de archivo"

	nc -l $PORT > inbox/$FILE_NAME

	echo "(11) SEND - Confirmación recepción datos"

	echo "OK_DATA_RCPT" | nc $IP_CLIENT $PORT

PREFIX1=`echo $MSG | cut -d " " -f 1`
FILE_NAME1=`echo $MSG | cut -d " " -f 2`
FILE_HASH1=`echo $MSG | cut -d " " -f 3`

HASH=`echo $FILE_NAME1 | md5sum | cut -d " " -f 1`

if [ "$PREFIX1" != "FIL_HASH" ]
        then
            echo "KO_FILE_NAME" | nc $IP_CLIENT $PORT
            exit 2
    fi


	if [ "$FILEHASH1" != "$HASH" ]
		then
			echo "KO_DATA_MD5" | nc $IP_CLIENT $PORT
        	exit 3
    	fi

    echo "OK_DATA_MD5" | nc $IP_CLIENT $PORT


	echo "Fin de la recepción"

	exit 0
