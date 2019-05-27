#!/bin/bash

ts=$(date +%s)
WORK=/tmp/booksAlive$ts
if [ ! -z "$1" ]
  then
    WORK=$1
fi
mkdir -p "$WORK"
echo "0. working with $WORK"

pagesdir=$WORK/pages
function extractPdfImages(){
    # extract images from PDF
    echo "1. extracting images in $1"
    sudo apt install -y poppler-utils
    mkdir -p "$pagesdir"
    pdfimages -j -p "$1" "$pagesdir/page"
    # only conver from pages 10 to 15 : testing settings!
    #pdfimages -f 10 -l 15 -j -p "$1" "$pagesdir/page"
}

function ocrFractured(){
    # recognize fractured german text in raw images:
    sudo apt install -y tessseract-ocr tesseract-ocr-deu-frak
    find "$pagesdir" -name "page*" -exec echo "OCR on {}" \; -exec tesseract {} {}text -l deu_frak  \;
}

function mergePages(){
    # wrap single .txt files into one: but keep divs around pages for easier structure in epub
    txtBook=$WORK/fullBook.txt
    find $pagesdir -name "*.txt" -exec echo "<div id={}>\n" > $txtBook \; -exec cat "{}" > $txtBook \; -exec echo "</div>" > $txtBook \;
    echo "created $txtBook"
}

extractPdfImages
ocrFractured
mergePages
