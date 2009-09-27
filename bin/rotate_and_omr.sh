#!/bin/bash

SCRIPT_DIR=`dirname $0`

echo "CORRECTION DE LA ROTATION :"
echo "==========================="

${SCRIPT_DIR}/correct_images_rotation.sh $1

echo ""
echo ""
echo "RECONNAISSANCE DES MARQUES :"
echo "============================"

${SCRIPT_DIR}/omr.sh $1

