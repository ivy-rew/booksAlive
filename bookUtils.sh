#!/bin/bash

ts=$(date +%s)
WORK=/tmp/booksAlive$ts
if [ ! -z "$1" ]
  then
    WORK=$1
fi
echo "0. working with $WORK"
mkdir -p "$WORK"

pdf=$2
pagesdir=$WORK/pages

function extractPdfImages(){
    # extract images from PDF
    echo "1. extracting images in $pdf"
    if ! [ -x "$(command -v pdfimages)" ]; then
      sudo apt install -y poppler-utils
    fi
    mkdir -p "$pagesdir"
    pdfimages -j -p "$pdf" "$pagesdir/page"
    # only conver from pages 10 to 15 : testing settings!
    #pdfimages -f 10 -l 15 -j -p "$pdf" "$pagesdir/page"
}

function ocrFractured(){
    # recognize fractured german text in raw images:
    if ! [ -x "$(command -v tesseract)" ]; then
      sudo apt install -y tessseract-ocr tesseract-ocr-deu-frak
    fi
    find "$pagesdir" -name "page*" -exec echo "OCR on {}" \; -exec tesseract {} {}text -l deu_frak  \;
}

function mergePages(){
    # wrap single .txt files into one: but keep divs around pages for easier structure in epub
    txtBook=$WORK/fullBook-$ts.txt
    for text in `ls -v $pagesdir/page*.txt`
    do
        echo "processing "+$text
        echo "<div id=$text>\n" >> $txtBook
        cat $text >> $txtBook 
        echo "</div>" >> $txtBook
    done
    echo "created $txtBook"
}
