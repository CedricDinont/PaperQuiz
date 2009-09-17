#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh
source ${SCRIPT_DIR}/xvfb_common.sh

INPUT_FILES=`ls ${QUIZ_DIR}/omr_input/*.jpg 2> /dev/null`

if [ "${INPUT_FILES}" = "" ] 
then
    echo "Error: No image in omr input directory."
    exit 1
fi

WHOAMI=`whoami`
if [ "$WHOAMI" = "apache" ]
then
    find_free_servernum
    cd /home/apache
    Xvfb :${SERVERNUM} -screen scrn0 800x600x16 2> /dev/null &
    XVFB_PID=$!
    export DISPLAY=:${SERVERNUM}
    export HOME=/home/apache
fi

OMR_LOG_FILE=${QUIZ_DIR}/omr.log
OMR_ERRORS_FILE=${QUIZ_DIR}/omr_errors/error_infos.txt

touch ${OMR_ERRORS_FILE}
touch ${OMR_LOG_FILE}       

ERRORS="false"

for file in ${INPUT_FILES} 
do 
    ERROR="false"
    BACKSLASHED_INPUT_DIR=`echo "${QUIZ_DIR}/omr_input/" | sed 's/\//\\\\\//g'`
    SHORT_FILE=`echo ${file} | sed "s/${BACKSLASHED_INPUT_DIR}//"`
    echo -n "OMR ${SHORT_FILE}...  "

    echo -n "1 "
    # image nb_vert nb_horz mark_width mark height min_top max_top min_left max_left min_bottom max_bottom min_right max_right binarization_threshold answer_threshold
    ${SCRIPT_DIR}/omr1 ${file}    10 45    2 10    1 6    2 9    94  98     91 98  58000  0.5 >> ${OMR_LOG_FILE} 
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    echo -n "2 "
    # image_in image_out data_out nb_vert nb_horz binarization _hreshold
    ${SCRIPT_DIR}/omr2 ${file} ${file}.output2.bmp ${file}.omr2_data 45 10 210 >> ${OMR_LOG_FILE}
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    if [ -f ${file}.output2.bmp ]
    then
	convert ${file}.output2.bmp ${file}_corrected2.jpg
    	rm -f ${file}.output2.bmp 2>&1 > /dev/null
    fi

    echo -n "3 "
   # fichier à tester, image analyser, sortie binaire, nombre de bandes hauteur, nombre de bandes largeur, seuil
    ${SCRIPT_DIR}/omr3 ${file} ${file}.output3.bmp ${file}.omr3_data 45 10 150 hg >> ${OMR_LOG_FILE}
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    if [ -f ${file}.output3.bmp ]
    then
	convert ${file}.output3.bmp ${file}_corrected3.jpg
    	rm -f ${file}.output3.bmp 2>&1 > /dev/null
    fi

    NB_DIFFS=0

    DIFF[0]="false"
    DIFF[1]="false"
    DIFF[2]="false"
	 
    diff -N ${file}.omr1_data ${file}.omr2_data > /dev/null 2>&1
    if (( $? != 0 ))
    then
       NB_DIFFS=$((${NB_DIFFS} + 1))
       DIFF[0]="true"
       echo "Warning: Difference between omr1 and omr2 results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    fi

    diff -N ${file}.omr1_data ${file}.omr3_data > /dev/null 2>&1
    if (( $? != 0 ))
    then
       NB_DIFFS=$((${NB_DIFFS} + 1)) 
       DIFF[1]="true"
       echo "Warning: Difference between omr1 and omr3 results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    fi
    
    diff -N ${file}.omr2_data ${file}.omr3_data > /dev/null 2>&1
    if (( $? != 0 ))
    then
       NB_DIFFS=$((${NB_DIFFS} + 1)) 
       DIFF[2]="true"
       echo "Warning: Difference between omr2 and omr3 results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    fi

    if [ ${NB_DIFFS} -lt 3 ]
    then
       echo "[OK]"
       OUTPUT_DIR=${QUIZ_DIR}/omr_output/
       if [ ${NB_DIFFS} -gt 0 ]
       then
           echo "Hint: ${SHORT_FILE} OMR data finally considered as correct." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
       fi
       if [ "${DIFF[0]}" == "false" -o "${DIFF[1]}" == "false" ]
       then
	   echo "Copying omr1_data to omr_data." >> ${OMR_LOG_FILE}
           cp ${file}.omr1_data ${file}.omr_data
       else
           echo "Copying omr2_data to omr_data." >> ${OMR_LOG_FILE}
           cp ${file}.omr2_data ${file}.omr_data
       fi
    else
       ERRORS="true"
       echo "[ERROR]"
       OUTPUT_DIR=${QUIZ_DIR}/omr_errors/
       echo "ERROR: Too much differences between OMR results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    fi

    mv -f ${file} ${file}.omr*_data ${file}_corrected*.jpg ${file}_binarized.jpg ${OUTPUT_DIR} > /dev/null 2>&1
    echo "=======================" >>  ${OMR_LOG_FILE}
done

kill ${XVFB_PID}

echo -n "All done. "

if [ "${ERRORS}" = "true" ]
then
    echo "THERE WERE ERRORS."
    exit 2
else
    echo "There were no error."
    exit 0
fi

