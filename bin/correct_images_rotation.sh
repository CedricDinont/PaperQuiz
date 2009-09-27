#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

INPUT_FILES=`ls ${QUIZ_DIR}/omr_input/ 2> /dev/null | grep "^[^(jpg)]*jpg$"`

if [ "${INPUT_FILES}" = "" ] 
then
    echo "Error: No image in omr input directory."
    exit 1
fi

WHOAMI=`whoami`
if [ "$WHOAMI" = "apache" ]
then
    export HOME=/home/apache
    export PATH=/usr/java/latest/bin/:$PATH
fi

OMR_ROTATE_LOG=${QUIZ_DIR}/omr_rotate.log
TMP_OMR_ROTATE_LOG=/tmp/${QUIZ_NAME}.omr_rotate.log

touch ${OMR_ROTATE_LOG}

for file in ${INPUT_FILES} 
do
	echo -n "${file}"

	file=${QUIZ_DIR}/omr_input/${file}

	# fichier à tester, image corrigée, seuil, position repere
	java -jar -Xmn128M -Xms256M -Xmx256M -Xss4096k -Djava.awt.headless=true ${SCRIPT_DIR}/omr_rotate.jar ${file} ${file}.rotated_temp.jpg 220 hg > ${TMP_OMR_ROTATE_LOG}

        ROTATION=$(grep 'alpha=' ${TMP_OMR_ROTATE_LOG} | cut -f 2 -d = )
	ORIENTATION=$(grep 'orientation=' ${TMP_OMR_ROTATE_LOG} | cut -f 2 -d = )
	# pour le crop on récupère les dimensions de l'image avant rotation, il faut donc tenir compte de l'orientation de départ
	if [ "${ORIENTATION}" == "1" -o "${ORIENTATION}" == "3" ]
	then
		WIDTH=$(identify -format '%h' ${file}.rotated_temp.jpg)
		HEIGHT=$(identify -format '%w' ${file}.rotated_temp.jpg)
	else
		WIDTH=$(identify -format '%w' ${file}.rotated_temp.jpg)
		HEIGHT=$(identify -format '%h' ${file}.rotated_temp.jpg)
	fi

	echo -n " (angle: ${ROTATION}) "
#	convert ${file}.rotated_temp.jpg -rotate ${ROTATION} -crop ${WIDTH}x${HEIGHT} ${file}.rotated.jpg
	convert ${file} -rotate ${ROTATION} ${file}.rotated.jpg
	rm ${file}.rotated_temp.jpg 2> /dev/null
	cat ${TMP_OMR_ROTATE_LOG} >> ${OMR_ROTATE_LOG}

	echo "[OK]"
done

rm ${TMP_OMR_ROTATE_LOG}

echo ""
echo "All done successfully."

