#!/bin/bash
echo -n "4 "
INPUT_FILES=`ls ./img/*.jpg 2> /dev/null`
for file in ${INPUT_FILES} 
do
	echo ${file}
	# fichier à tester, image analysée, sortie binaire, seuil, position repere
	java -jar -Xmn128M -Xms256M -Xmx256M -Xss2048k dist/omr4.jar ${file} ${file}.output3.jpeg ${file}.omr4_data 200 hg
	if (( $? != 0 ))
	then
		ERROR="true"
	fi
done
