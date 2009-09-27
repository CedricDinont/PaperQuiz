#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

WHOAMI=`whoami`
if [ "$WHOAMI" = "apache" ]
then
    export HOME=/home/apache
    export PATH=/usr/java/latest/bin/:$PATH
fi

java -Xmx512m -cp ${SCRIPT_DIR}/mail/:${SCRIPT_DIR}/mail/mail.jar FetchMail ${QUIZ_DIR}/omr_input/

if (( $? != 0 )) 
then
    echo "There were errors."
else
    echo "All done successfully."
fi
