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
    echo -n "OMR ${file}...  "

    # image nb_vert nb_horz mark_width mark height min_top max_top min_left max_left min_bottom max_bottom min_right max_right
    ${SCRIPT_DIR}/omr1 ${file}    10 45    2 10    2 6    2 9    94  98     91 98  >> ${OMR_LOG_FILE}
    if (( $? == 0 ))
    then
       ERRORS="true"
    fi

    ${SCRIPT_DIR}/omr1 ${file}    10 45    2 10    2 6    2 9    94  98     91 98  >> ${OMR_LOG_FILE}
    if (( $? == 0 ))
    then
       ERRORS="true"
    fi

    diff ${file}.omr1_data ${file}.omr1_data
    if (( $? == 0 ))
    then
       ERRORS="true"
       echo "- Difference between ${file}.omr1_data and ${file}.omr2_data." >> ${OMR_ERRORS_FILE}
    fi

    if [ ${ERRORS} = "true" ]
    then
       OUTPUT_DIR=${QUIZ_DIR}/omr_output/
       echo "[OK]"
    else
       echo "[ERROR]"
       OUTPUT_DIR=${QUIZ_DIR}/omr_errors/
    fi

    mv ${file} ${file}.omr_data ${file}_corrected.jpg ${file}_binarized.jpg ${OUTPUT_DIR}
    echo "=======================" >>  ${OMR_LOG_FILE}
done

echo -n "All done. "

if [ ${ERRORS} = "true" ]
then
    echo "There were errors. Resolve them in ${QUIZ_NAME}/omr_errors/ directory and call omr_errors_resolved.sh before continuing with prepare_correction.sh."
    exit 2
else
    echo "There were no error."
    exit 0
fi
