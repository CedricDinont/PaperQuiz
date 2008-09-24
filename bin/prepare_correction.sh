#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

OMR_DATA_FILES=`ls ${QUIZ_DIR}/omr_output/*.omr1_data  2> /dev/null`

QUIZ_PART_NB=0
echo $QUIZ_PARTS
for QUIZ_PART in ${QUIZ_PARTS} 
do
echo "Creating data for '${QUIZ_PART}'"

OUTPUT_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.students_answers

echo -n "" > ${OUTPUT_FILE}

for OMR_DATA_FILE in ${OMR_DATA_FILES}
do
    echo "  Parsing ${OMR_DATA_FILE}."
    OUTPUT_TEXT=`awk  -v min=${QUIZ_PARTS_MIN_QUESTIONS[$QUIZ_PART_NB]} -v max=${QUIZ_PARTS_MAX_QUESTIONS[$QUIZ_PART_NB]} '
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
        login[NR] = i - 1
     }
  }
}
NR == 5 {
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
fi

done
QUIZ_PART_NB=$((${QUIZ_PART_NB} + 1))
done

echo "All done successfully."
