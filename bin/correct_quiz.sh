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
  CORRECTION_MARK_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.correction_marks.csv

  awk -f ${SCRIPT_DIR}/correct_quiz_part.awk -v bad=-0.5 -v outputmode=ooffice -v students="/home/ced/students.txt" -v corrige="${MARKING_FILE}" -v ooffile="${CORRECTION_MARK_FILE}" ${STUDENTS_ANSWERS_FILE}

#  if [ -f ${CORRECTION_FILE} ]
#  then
#      awk -f ${SCRIPT_DIR}/correct_quiz_part.awk -v bad=-0.5 -v students=${CORRECTION_FILE} ${MARKING_FILE} ${CORRECTION_MARK_FILE}
#  fi

  echo ""

done

echo "All done successfully."
