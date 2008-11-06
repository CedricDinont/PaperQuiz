#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

java -cp ${SCRIPT_DIR}/mail/:${SCRIPT_DIR}/mail/mail.jar FetchMail ${QUIZ_DIR}/omr_input/

if (( $? != 0 )) 
then
    echo "There were errors."
else
    echo "All done successfully."
fi
