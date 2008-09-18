#!/bin/bash

if (( $# != 1 ))
then
    echo "Usage: $0 student_login (pXXYYY)."
    exit -1
fi

STUDENT_LOGIN=$1

NAME=`ldapsearch -h campus.isen.fr -x -u -b "ou=Students,l=Lille,o=isen,c=fr" "uid=${STUDENT_LOGIN}" | grep -E "^cn:" | cut -d " " -f 2-`
 
if [ "${NAME}" = "" ]
then
    exit 1
else
    echo ${NAME}
    exit 0
fi
