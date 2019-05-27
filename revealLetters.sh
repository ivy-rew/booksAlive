#!/bin/bash

PDF=$1
PDF_BASE=`basename $PDF`
WORK="$(pwd)/work_$PDF_BASE"

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

source $MY_PATH/bookUtils.sh "$WORK" "$PDF"

extractPdfImages
ocrFractured
mergePages
