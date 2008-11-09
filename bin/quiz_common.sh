#!/bin/bash

# This file is sourced by scripts that work on quizes.

if (( $# < 1 )); then
    echo "Usage: $0 quiz_name."
    exit -1
fi

QUIZ_NAME=$1

QUIZ_BASE_DIR=${SCRIPT_DIR}/../quiz_data
QUIZ_DIR=${QUIZ_BASE_DIR}/${QUIZ_NAME}

if [ -f ${QUIZ_DIR}/quiz.conf ]
then

QUIZ_PARTS=`awk 'BEGIN {FS=":" } 
/#.*/ { } 
NF==3 { print $1}' ${QUIZ_DIR}/quiz.conf`

QUIZ_PARTS_MIN_QUESTIONS=( `awk 'BEGIN { FS=":" } 
/#.*/ { } 
NF==3 { printf "%s ", $2}' ${QUIZ_DIR}/quiz.conf` )

QUIZ_PARTS_MAX_QUESTIONS=( `awk 'BEGIN { FS=":" } 
/#.*/ { } 
NF==3 { printf "%s ", $3}' ${QUIZ_DIR}/quiz.conf` )

fi

