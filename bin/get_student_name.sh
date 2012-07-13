#!/bin/bash

if (( $# != 1 ))
then
    echo "Usage: $0 student_login (pXXYYY)."
    exit -1
fi

STUDENT_LOGIN=$1

SURNAME=`ldapsearch -h ldapserver -x -u -b "ou=Students,l=Lille,o=isen,c=fr" "uid=${STUDENT_LOGIN}" | grep -E "^sn:" | cut -d " " -f 2-`
GIVEN_NAME=`ldapsearch -h ldapserver -x -u -b "ou=Students,l=Lille,o=isen,c=fr" "uid=${STUDENT_LOGIN}" | grep -E "^givenName:" | cut -d " " -f 2-`

if [ "${SURNAME}" = "" ]
then
    exit 1
else
    echo "${SURNAME};${GIVEN_NAME}"
    exit 0
fi
