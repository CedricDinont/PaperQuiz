#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

export LANG=C

QUIZ_PART_NB=0
for QUIZ_PART in ${QUIZ_PARTS} 
do
  echo "Correcting ${QUIZ_PART}."

  STUDENTS_ANSWERS_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.students_answers
  MARKING_FILE=${QUIZ_DIR}/${QUIZ_PART}.marking
  STUDENTS_FILE=${QUIZ_DIR}/correction/students
  STUDENTS_MARKS_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.students_marks
  CORRECTION_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.correction_answers
  CORRECTION_MARK_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.correction_marks.csv
  OOFILE=${QUIZ_DIR}/correction/${QUIZ_NAME}.${QUIZ_PART}.ods
  CORNERS_FILE=${QUIZ_DIR}/correction/${QUIZ_PART}.corners

  if [ ! -e ${STUDENTS_ANSWERS_FILE} ] || [ ! -e ${MARKING_FILE} ] || [ ! -e ${STUDENTS_FILE} ] 
  then
	echo "Missing file. Can't correct ${QUIZ_PART}."
	continue
  fi

  echo "    Creating .csv file."
  awk -f ${SCRIPT_DIR}/correct_quiz_part.awk -v students="${STUDENTS_FILE}" -v corrige="${MARKING_FILE}" -v ooffile="${CORRECTION_MARK_FILE}" -v cornersfile="${CORNERS_FILE}" -v min_question="${QUIZ_PARTS_MIN_QUESTIONS[$QUIZ_PART_NB]}" -v max_question="${QUIZ_PARTS_MAX_QUESTIONS[$QUIZ_PART_NB]}" ${STUDENTS_ANSWERS_FILE} 

CHART_CORNERS=`awk 'BEGIN { FS=" " }
NR == 1 { print $1 } ' ${CORNERS_FILE}`
LAST_COLUMN=`awk 'BEGIN { FS=" " }
NR == 2 { print $1 } ' ${CORNERS_FILE}`
AVERAGE=`awk 'BEGIN { FS=" " }
NR == 3 { print $1 } ' ${CORNERS_FILE}`
FIRST_FREE_LINE=`awk 'BEGIN { FS=" " }
NR == 4 { print $1 } ' ${CORNERS_FILE}`

  echo "    Creating .ods file."
  ${SCRIPT_DIR}/convert_csv_to_oofile.sh  ${CORRECTION_MARK_FILE}  ${OOFILE} "${CHART_CORNERS}" "${LAST_COLUMN}" "${AVERAGE}" "${FIRST_FREE_LINE}" 

#  if [ -f ${CORRECTION_FILE} ]
#  then
#      awk -f ${SCRIPT_DIR}/correct_quiz_part.awk -v students=${CORRECTION_FILE} ${MARKING_FILE} ${CORRECTION_MARK_FILE}
#  fi

  echo ""

  QUIZ_PART_NB=$((${QUIZ_PART_NB} + 1))

done

echo "All done successfully."
