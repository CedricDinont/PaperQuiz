#!/bin/bash
echo -n "4 "
INPUT_FILES=`ls ../img/*.jpg 2> /dev/null`
for file in ${INPUT_FILES} 
do
	echo ${file}
	# fichier à tester, image corrigée, seuil, position repere
	java -jar -Xmn128M -Xms256M -Xmx256M -Xss4096k -Djava.awt.headless=true dist/omr_rotate.jar ${file} ${file}.corrected.jpeg 220 hg > log_omr_rotate
	ORIENTATION=$(grep 'orientation=' log_omr_rotate | cut -f 2 -d = )
	echo ${ORIENTATION}
	# pour le crop on récupère les dimensions de l'image avant rotation, il faut donc tenir compte de l'orientation de départ
	if [ "${ORIENTATION}" == "1" -o "${ORIENTATION}" == "3" ]
	then
		WIDTH=$(identify -format '%h' ${file}.corrected.jpeg)
		HEIGHT=$(identify -format '%w' ${file}.corrected.jpeg)
	else
		WIDTH=$(identify -format '%w' ${file}.corrected.jpeg)
		HEIGHT=$(identify -format '%h' ${file}.corrected.jpeg)
   fi
	ROTATION=$(grep 'alpha=' log_omr_rotate | cut -f 2 -d = )
	echo ${WIDTH}x${HEIGHT}_${ROTATION}
	convert -rotate ${ROTATION} ${file}.corrected.jpeg ${file}.corrected2.jpeg
	convert -crop ${WIDTH}x${HEIGHT} ${file}.corrected2.jpeg ${file}.corrected3.jpeg
	cp ${file}.corrected3-0.jpeg ${file}.corrected.jpeg
	rm ${file}.corrected3-* ${file}.corrected2.jpeg
done
rm log_omr_rotate
