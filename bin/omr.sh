#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

INPUT_FILES=`ls ${QUIZ_DIR}/omr_input/*.jpg 2> /dev/null`

if [ "${INPUT_FILES}" = "" ] 
then
    echo "Error: No image in omr input directory."
    exit 1
fi

OMR_LOG_FILE=${QUIZ_DIR}/omr.log
OMR_ERRORS_FILE=${QUIZ_DIR}/omr_errors/error_infos.txt

touch ${OMR_ERRORS_FILE}
touch ${OMR_LOG_FILE}       

ERRORS="false"

for file in ${INPUT_FILES} 
do
    ERROR="false"
    echo -n "OMR ${file}...  "

    echo -n "1 "
    # image nb_vert nb_horz mark_width mark height min_top max_top min_left max_left min_bottom max_bottom min_right max_right binarization_threshold answer_threshold
    ${SCRIPT_DIR}/omr1 ${file}    10 45    2 10    1 6    2 9    94  98     91 98  55000  0.5 >> ${OMR_LOG_FILE} 
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    echo -n "2 "
    # convert ${file} -rotate 270 -type TrueColor ${file}.bmp
    WHOAMI=`whoami`
    if [ "$WHOAMI" = "apache" ]
    then
	cd /home/apache
	export DISPLAY=:0
	export HOME=/home/apache
    fi
    # image_in image_out data_out nb_vert nb_horz binarization threshold
    xvfb-run -a ${SCRIPT_DIR}/omr2 ${file} ${file}.output.bmp ${file}.omr2_data 45 10 200 >> ${OMR_LOG_FILE}
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    convert ${file}.output.bmp ${file}_corrected2.jpg
    rm -f ${file}.bmp ${file}.output.bmp 2>&1 > /dev/null

    diff ${file}.omr1_data ${file}.omr2_data 2>&1 > /dev/null
    if (( $? != 0 ))
    then
       ERROR="true"
       echo "Difference between ${file}.omr1_data and ${file}.omr2_data." >> ${OMR_ERRORS_FILE}
    fi

    if [ "${ERROR}" = "true" ]
    then
       ERRORS="true"
       echo "[ERROR]"
       OUTPUT_DIR=${QUIZ_DIR}/omr_errors/
    else
       echo "[OK]"
       OUTPUT_DIR=${QUIZ_DIR}/omr_output/
    fi

    mv -f ${file} ${file}.omr*_data ${file}_corrected.jpg ${file}_corrected2.jpg ${file}_binarized.jpg ${OUTPUT_DIR} 2>&1 > /dev/null
    echo "=======================" >>  ${OMR_LOG_FILE}
done

echo -n "All done. "

if [ "${ERRORS}" = "true" ]
then
    echo "There were errors. Resolve them in ${QUIZ_NAME}/omr_errors/ directory and call omr_errors_resolved.sh before continuing with prepare_correction.sh."
    exit 2
else
    echo "There were no error."
    exit 0
fi
