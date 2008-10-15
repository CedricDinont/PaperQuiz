#!/bin/bash

SCRIPT_DIR=`dirname $0`

python ${SCRIPT_DIR}/mm2quiz.py $1 $1.html $2
