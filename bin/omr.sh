#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh
source ${SCRIPT_DIR}/xvfb_common.sh

INPUT_FILES=`ls ${QUIZ_DIR}/omr_input/ 2> /dev/null | grep "^[^(jpg)]*jpg$"`

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
    original_file=${file}

    if [ -e ${QUIZ_DIR}/omr_input/${file}.rotated.jpg ]
    then
	SHORT_FILE=$file.rotated.jpg
	file=${QUIZ_DIR}/omr_input/${file}.rotated.jpg
    else
	SHORT_FILE=${file}
        file=${QUIZ_DIR}/omr_input/${file}
    fi

    echo -n "OMR ${SHORT_FILE}...  "

    echo -n "1 "
    # image prefix_for_output_filenames nb_vert nb_horz mark_width mark height min_top max_top min_left max_left min_bottom max_bottom min_right max_right binarization_threshold answer_threshold
    ${SCRIPT_DIR}/omr1 ${file} ${original_file}    10 45    2 10    1 6    2 9    94  98     91 98  58000  0.5 >> ${OMR_LOG_FILE} 
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    echo -n "2 "
    # image_in image_out data_out nb_vert nb_horz binarization_threshold
    ${SCRIPT_DIR}/omr2 ${file} ${original_file}.output2.bmp ${original_file}.omr2_data 45 10 210 >> ${OMR_LOG_FILE}
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    if [ -f ${original_file}.output2.bmp ]
    then
	convert ${original_file}.output2.bmp ${original_file}_corrected2.jpg
    	rm -f ${original_file}.output2.bmp 2>&1 > /dev/null
    fi

    echo -n "3 "
   # fichier à tester, image analyser, sortie binaire, nombre de bandes hauteur, nombre de bandes largeur, seuil
    ${SCRIPT_DIR}/omr3 ${file} ${original_file}.output3.bmp ${original_file}.omr3_data 45 10 150 hg >> ${OMR_LOG_FILE}
    if (( $? != 0 ))
    then
       ERROR="true"
    fi

    if [ -f ${original_file}.output3.bmp ]
    then
	convert ${original_file}.output3.bmp ${original_file}_corrected3.jpg
    	rm -f ${original_file}.output3.bmp 2>&1 > /dev/null
    fi

    NB_DIFFS=0

    DIFF[0]="false"
    DIFF[1]="false"
    DIFF[2]="false"

    if [ ! -e ${original_file}.omr1_data ] || [ ! -e ${original_file}.omr2_data ]
    then
	        NB_DIFFS=$((${NB_DIFFS} + 1))
                DIFF[0]="true"
		echo "Warning: No result given by omr1 or omr2 for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    else
	diff -N ${original_file}.omr1_data ${original_file}.omr2_data > /dev/null 2>&1
    	if (( $? != 0 ))
    	then
       		NB_DIFFS=$((${NB_DIFFS} + 1))
      		DIFF[0]="true"
       		echo "Warning: Difference between omr1 and omr2 results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    	fi
    fi

    if [ ! -e ${original_file}.omr1_data ] || [ ! -e ${original_file}.omr3_data ]
    then
                NB_DIFFS=$((${NB_DIFFS} + 1))
                DIFF[1]="true"
                echo "Warning: No result given by omr1 or omr3 for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    else
	diff -N ${original_file}.omr1_data ${original_file}.omr3_data > /dev/null 2>&1
    	if (( $? != 0 ))
    	then
       		NB_DIFFS=$((${NB_DIFFS} + 1)) 
     		DIFF[1]="true"
       		echo "Warning: Difference between omr1 and omr3 results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    	fi
    fi
    
    if [ ! -e ${original_file}.omr2_data ] || [ ! -e ${original_file}.omr3_data ]
    then
                NB_DIFFS=$((${NB_DIFFS} + 1))
                DIFF[2]="true"
                echo "Warning: No result given by omr2 or omr3 for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    else
    	diff -N ${original_file}.omr2_data ${original_file}.omr3_data > /dev/null 2>&1
    	if (( $? != 0 ))
    	then
       		NB_DIFFS=$((${NB_DIFFS} + 1)) 
       		DIFF[2]="true"
       		echo "Warning: Difference between omr2 and omr3 results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    	fi
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
           cp ${original_file}.omr1_data ${original_file}.omr_data
       else
           echo "Copying omr2_data to omr_data." >> ${OMR_LOG_FILE}
           cp ${original_file}.omr2_data ${original_file}.omr_data
       fi
    else
       ERRORS="true"
       echo "[ERROR]"
       OUTPUT_DIR=${QUIZ_DIR}/omr_errors/
       echo "ERROR: Too much differences between OMR results for ${SHORT_FILE}." | tee -a ${OMR_ERRORS_FILE} ${OMR_LOG_FILE} 1>&2
    fi

    mv -f ${QUIZ_DIR}/omr_input/${original_file} ${file} ${original_file}.omr*_data ${original_file}_corrected*.jpg ${original_file}_binarized.jpg ${OUTPUT_DIR} > /dev/null 2>&1
    echo "=======================" >>  ${OMR_LOG_FILE}
done

kill ${XVFB_PID}

echo ""
echo -n "All done. "

if [ "${ERRORS}" = "true" ]
then
    echo "THERE WERE ERRORS."
    exit 2
else
    echo "There were no error."
    exit 0
fi

