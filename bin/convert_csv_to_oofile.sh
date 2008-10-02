#!/bin/bash

SCRIPT_DIR=`dirname $0`
export LANG=C

xvfb-run -a oocalc ${SCRIPT_DIR}/convert_csv_to_openoffice_macros.ods -invisible -nologo -headless -nocrashreport -norestore "macro://convert_csv_to_openoffice_macros/Standard.quiz.SaveAsOO(\"$1\", \"$2\", \"$3\", \"$4\", \"$5\", \"$6\")" 2> /dev/null
