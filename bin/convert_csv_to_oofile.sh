#!/bin/bash

SCRIPT_DIR=`dirname $0`
export LANG=C

WHOAMI=`whoami`
if [ "$WHOAMI" = "apache" ]
then
    export HOME=/home/apache
    export DISPLAY=:0
fi

#ooffice -nocrashreport -norestore -headless -nodefault ${SCRIPT_DIR}/convert_csv_to_openoffice_macros.ods  "macro://convert_csv_to_openoffice_macros/Standard.quiz.SaveAsOO(\"$1\", \"$2\", \"$3\", \"$4\", \"$5\", \"$6\")" 
#2> /dev/null -invisible -nologo -headless -nocrashreport -norestore

ooffice -nocrashreport -norestore -nodefault "macro:///Standard.quiz.SaveAsOO(\"$1\", \"$2\", \"$3\", \"$4\", \"$5\", \"$6\")" # 2> /dev/null

# -headless