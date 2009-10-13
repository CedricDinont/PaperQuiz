#!/bin/bash
echo -n "4 "
INPUT_FILES=`ls ../img_dur/*.jpeg 2> /dev/null`
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
		WIDTH=$(gm identify -format '%h' ${file})
		HEIGHT=$(gm identify -format '%w' ${file})
	else
		WIDTH=$(gm identify -format '%w' ${file})
		HEIGHT=$(gm identify -format '%h' ${file})
   fi
	ROTATION=$(grep 'alpha=' log_omr_rotate | cut -f 2 -d = )
	echo ${WIDTH}x${HEIGHT}_${ROTATION}
	gm convert -rotate ${ROTATION} ${file} ${file}.corrected.jpeg
	gm convert -crop ${WIDTH}x${HEIGHT} ${file}.corrected.jpeg ${file}.corrected2.jpeg
	cp ${file}.corrected2.jpeg.0 ${file}.corrected.jpeg
	rm ${file}.corrected2*
done
rm log_omr_rotate
