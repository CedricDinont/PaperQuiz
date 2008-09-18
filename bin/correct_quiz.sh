#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

for QUIZ_PART in ${QUIZ_PARTS} 
do
  echo "Correcting ${QUIZ_PART}."

  STUDENTS_ANSWERS_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.students_answers
  MARKING_FILE=${QUIZ_DIR}/${QUIZ_PART}.marking
  STUDENTS_MARKS_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.students_marks
  CORRECTION_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.correction_answers
  CORRECTION_MARK_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.correction_marks

  ${SCRIPT_DIR}/correct_quiz_part.sh ${STUDENTS_ANSWERS_FILE} ${MARKING_FILE} ${STUDENTS_MARKS_FILE}

  if [ -f ${CORRECTION_FILE} ]
  then
      ${SCRIPT_DIR}/correct_quiz_part.sh ${CORRECTION_FILE} ${MARKING_FILE} ${CORRECTION_MARK_FILE}
  fi

  echo ""

done

echo "All done successfully."
