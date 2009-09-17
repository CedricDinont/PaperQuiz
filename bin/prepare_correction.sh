#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

IMAGE_FILES=`ls ${QUIZ_DIR}/omr_output/ 2> /dev/null | grep "^[^(jpg)]*jpg$"`

QUIZ_PART_NB=0
echo $QUIZ_PARTS
for QUIZ_PART in ${QUIZ_PARTS} 
do
echo "======================================="
echo "Creating data for '${QUIZ_PART}'"

NB_STUDENTS=0
OUTPUT_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.students_answers

echo "First question: ${QUIZ_PARTS_MIN_QUESTIONS[$QUIZ_PART_NB]}"
echo "Last question: ${QUIZ_PARTS_MAX_QUESTIONS[$QUIZ_PART_NB]}"

echo -n "" > ${OUTPUT_FILE}

for IMAGE_FILE in ${IMAGE_FILES}
do
    if [ -e ${QUIZ_DIR}/omr_output/${IMAGE_FILE}.mmr_data ] 
    then
	OMR_DATA_FILE=${QUIZ_DIR}/omr_output/${IMAGE_FILE}.mmr_data
    elif [ -e ${QUIZ_DIR}/omr_output/${IMAGE_FILE}.omr_data ] 
    then
	OMR_DATA_FILE=${QUIZ_DIR}/omr_output/${IMAGE_FILE}.omr_data    
    elif [ -e ${QUIZ_DIR}/omr_output/${IMAGE_FILE}.omr1_data ]
    then
	echo "Error: No mmr_data or omr_data file found for ${IMAGE_FILE}. Failing back to omr1_data to continue." >2
	OMR_DATA_FILE=${QUIZ_DIR}/omr_output/${IMAGE_FILE}.omr1_data    
    else
       echo "Error: No mr_data found for ${IMAGE_FILE}."
       exit -1
    fi
    
    BACKSLASHED_OMR_OUTPUT_DIR=`echo "${QUIZ_DIR}/omr_output/" | sed 's/\//\\\\\//g'`
    SHORT_FILE=`echo ${OMR_DATA_FILE} | sed "s/${BACKSLASHED_OMR_OUTPUT_DIR}//"`
    echo "    Parsing ${SHORT_FILE}."
    OUTPUT_TEXT=`awk  -v min=${QUIZ_PARTS_MIN_QUESTIONS[$QUIZ_PART_NB]} -v max=${QUIZ_PARTS_MAX_QUESTIONS[$QUIZ_PART_NB]} -v file=${OMR_DATA_FILE} '
BEGIN {
  FS=" "
  login[1] = -1
  login[2] = -1
  login[3] = -1
  login[4] = -1
  login[5] = -1
  question_number = 1
 }
NR <= 5 {
  for (i = 1; i <= NF; i = i + 1) {
     if ($i == "1") {
	if (login[NR] != -1) {
		print "Error: Two marks on line ", NR, " in file ", file > "/dev/stderr"
		exit 1
	}
        login[NR] = i - 1
     }
  }
}
NR == 5 {
    if ((login[1] == -1) || (login[2] == -1) || (login[3] == -1) || (login[4] == -1) || (login[4] == -1)) {
	    print "Error: Incomplete login in file ", file > "/dev/stderr"
	    exit 2
    }
  if (login[1] == 1) {
    printf "f"
  } else {
    printf "p"
  }
  printf "%d%d%d%d%d;", login[1], login[2], login[3], login[4], login[5]
}
NR > 5 {
  for (i = 1; i <= NF; i = i + 1) {
    if (i <= 5) {
      answers[NR-5,i] = $i
    } else {
      answers[(NR-5)+40,i-5] = $i
    }
  }
  nb_questions = nb_questions + 1
}
END {
  for (question_number = 1; question_number < 80; question_number = question_number + 1) {
    if ((question_number >= min) && (question_number <= max)) {
    first_answer=1
    for (i = 1; i <= 5; i = i + 1) {
      if (answers[question_number,i] == "1") {
        if (first_answer == 1)
          first_answer = 0
        else
          printf "\\\\"
        printf "R%d", i
      }
    }
    printf ";"
  }
  }
 print ""
}

' ${OMR_DATA_FILE}`




LOGIN=`echo ${OUTPUT_TEXT} | cut -d ";" -f 1`
if [ "${LOGIN}" = "p00000" ]
then
    echo ${OUTPUT_TEXT} > ${QUIZ_DIR}/correction/${QUIZ_PART}.correction_answers
else
    echo ${OUTPUT_TEXT} >> ${OUTPUT_FILE}
    NB_STUDENTS=$((${NB_STUDENTS} + 1))
fi

done
QUIZ_PART_NB=$((${QUIZ_PART_NB} + 1))
echo ${NB_STUDENTS} > ${OUTPUT_FILE}.nb_students
echo ""
done

echo "All done successfully."
