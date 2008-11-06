#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

IMAGE_FILES=`ls ${QUIZ_DIR}/omr_errors/ 2> /dev/null | grep "^[^(jpg)]*jpg$"`

for IMAGE_FILE in ${IMAGE_FILES}
do
    if [ -e ${QUIZ_DIR}/omr_errors/${IMAGE_FILE}.mmr_data ] 
    then
	echo "Moving ${IMAGE_FILE} to omr_output/."
	mv ${QUIZ_DIR}/omr_errors/${IMAGE_FILE}* ${QUIZ_DIR}/omr_output/
    else
        echo "Not moving ${IMAGE_FILE}."
    fi
done

