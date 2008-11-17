#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

STUDENTS_FILE=${QUIZ_DIR}/correction/students
echo -n "" > ${STUDENTS_FILE}
FIRST_QUIZ_PART=`echo "$QUIZ_PARTS" | head -n 1`

LOGINS=`awk 'BEGIN {FS=";" }
 { print $1}' ${QUIZ_DIR}/correction/${FIRST_QUIZ_PART}.students_answers`

for LOGIN in ${LOGINS}
do
    NAME=`${SCRIPT_DIR}/get_student_name.sh ${LOGIN}`
    echo "${LOGIN} -> ${NAME}"
    echo "${NAME};${LOGIN}" >> ${STUDENTS_FILE}
done

echo "Done."
