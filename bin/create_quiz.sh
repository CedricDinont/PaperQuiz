#!/bin/bash

SCRIPT_DIR=`dirname $0`
source ${SCRIPT_DIR}/quiz_common.sh

if [ -d ${QUIZ_DIR} ] 
then
    echo "Error: Quiz directory already exists."
    exit 1
fi

mkdir ${QUIZ_DIR}/
mkdir ${QUIZ_DIR}/omr_input/
mkdir ${QUIZ_DIR}/omr_output/
mkdir ${QUIZ_DIR}/omr_errors/
mkdir ${QUIZ_DIR}/omr_tmp/
mkdir ${QUIZ_DIR}/correction/
mkdir ${QUIZ_DIR}/correction_errors/

echo "# Ce fichier doit contenir la répartition des questions 
# en fonction des matières.
# On décrit une matière par ligne sous la forme :
#      nom_matiere:question_debut:question_fin

" > ${QUIZ_DIR}/quiz.conf

echo "# Fichier de bareme.
# Chaque ligne décrit une question sous la forme :
#     numero_question;nombre_reponses_proposees;reponses_attendues;points_bonne_reponse;points_mauvaise_reponse;coefficient;bonus
# reponses_attendues est une suite de termes Ri séparés par des \ où i est le numéro d'une réponse attendue
# (par exemple : R1 ou R2\R4).
# 
# Exemple: 1;4;R2\R3;1,-0.5;1;0

" > ${QUIZ_DIR}/sample.marking

echo "Quiz $1 created."
