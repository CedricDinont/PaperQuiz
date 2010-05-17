#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

PID=$2

echo `date`
echo "Wait for : "
echo ${PID}


echo "Running
${PID}" > ${QUIZ_DIR}/processes/current_process

#wait ${PID}
while ps -p ${PID} > /dev/null
do
    sleep 1
done


mv /tmp/${QUIZ_NAME}.stdout ${QUIZ_DIR}/processes/${PID}.stdout
mv /tmp/${QUIZ_NAME}.stderr ${QUIZ_DIR}/processes/${PID}.stderr
mv /tmp/${QUIZ_NAME}.info ${QUIZ_DIR}/processes/${PID}.info
date +"%s" >> ${QUIZ_DIR}/processes/${PID}.info

echo "Finished
${PID}" > ${QUIZ_DIR}/processes/current_process

echo `date`
echo "Finished for : "
echo ${PID}
