#!/bin/bash

IP_LOCAL=`ip address | grep -i inet | grep enp0s3 | sed "s/^ *//g" | cut -d " " -f 2 | cut -d "/" -f 1`


echo "La IP del servidor es: $IP_LOCAL"

PORT="4242"

echo "Servidor HMTP"

echo "(0) LISTEN - Levantando el servidor"

MSG=`nc -l $PORT`

HANDSHAKE=`echo $MSG | cut -d " " -f 1`
IP_CLIENT=`echo $MSG | cut -d " " -f 2`
IP_CLIENT_MD5=`echo $MSG | cut -d " " -f 3`

echo "(3) SEND - Confirmación Handshake"

MD5_IP=`echo $IP_CLIENT | md5sum | cut -d " " -f 1`

if [ "$IP_CLIENT_MD5" != "$MD5_IP" ]
then
	echo "ERROR 1: IP mal formada"
	exit 1
fi

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

echo "(12) LISTEN - MD5 de los datos"

MSG=`nc -l $PORT`

PREFIX=`echo $MSG | cut -d " " -f 1`
DATA_MD5=`echo $MSG | cut -d " " -f 2`

if [ "$PREFIX" != "DATA_MD5" ]
then
	echo "KO_MD5_PREFIX" | nc $IP_CLIENT $PORT
	exit 4
fi


FILE_MD5=`cat inbox/$FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$DATA_MD5" != "$FILE_MD5" ]
then
	echo "KO_DATA_MD5" | nc $IP_CLIENT $PORT
	exit 5
fi

echo "OK_DATA_MD5" | nc $IP_CLIENT $PORT

echo "Fin de la recepción"

exit 0
