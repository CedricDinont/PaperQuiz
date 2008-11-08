#!/bin/bash

SCRIPT_DIR=`dirname $0`
export LANG=C

WHOAMI=`whoami`
if [ "$WHOAMI" = "apache" ]
then
    export HOME=/home/apache
    export DISPLAY=:0
fi

Xvfb :99 -screen scrn0 800x600x16 &
XVFB_PID=$!
ooffice -nocrashreport -norestore -headless -nodefault -display :99 ${SCRIPT_DIR}/convert_csv_to_openoffice_macros.ods  "macro://convert_csv_to_openoffice_macros/Standard.quiz.SaveAsOO(\"$1\", \"$2\", \"$3\", \"$4\", \"$5\", \"$6\")"
#ooffice -headless -nocrashreport -norestore -nodefault -display :99 "macro:///Standard.quiz.SaveAsOO(\"$1\", \"$2\", \"$3\", \"$4\", \"$5\", \"$6\")" # 2> /dev/null
kill ${XVFB_PID}

