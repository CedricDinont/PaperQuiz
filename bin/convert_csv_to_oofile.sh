#!/bin/bash

SCRIPT_DIR=`dirname $0`
export LANG=C

oocalc ${SCRIPT_DIR}/convert_csv_to_openoffice_macros.ods -invisible "macro://convert_csv_to_openoffice_macros/Standard.quiz.SaveAsOO(\"$1\", \"$2\", \"$3\", \"$4\", \"$5\", \"$6\")" 2> /dev/null