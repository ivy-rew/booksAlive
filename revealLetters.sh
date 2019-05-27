#!/bin/bash

WORK=$(pwd)
PDF=$1
source bookUtils.sh $WORK $PDF

extractPdfImages
ocrFractured
mergePages
