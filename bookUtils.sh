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
bookName=`basename $pdf`
bookName=${bookName:0:-4}

pagesdir="$WORK/pages"
function extractPdfImages(){
    # extract images from PDF
    echo "1. extracting images in $pdf"
    if ! [ -x "$(command -v pdfimages)" ]; then
      sudo apt install -y poppler-utils
    fi
    mkdir -p "$pagesdir"
    pdfimages -png -p "$pdf" "$pagesdir/page"
    # only convert from pages 10 to 15 : testing settings!
    #pdfimages -f 10 -l 15 -j -p "$pdf" "$pagesdir/page"
}

textdir="$WORK/text"
function ocrFractured(){
    LANG="deu_frak"
    if [ ! -z "$1" ]; then
        LANG=$1
    fi
    # recognize fractured german text in raw images:
    if ! [ -x "$(command -v tesseract)" ]; then
      sudo apt install -y tesseract-ocr tesseract-ocr-deu-frak
    fi
    mkdir -p "$textdir"
    for img in `ls -v $pagesdir/page*.png`
    do
        png=`basename $img`
        page=${png:0:-4} #no-file-ext
        md=$page.md
        if ! [ -f "$textdir/$md" ]; then        
            echo "OCR on $img"
            tesseract $img $textdir/$page -l $LANG
            mv "$textdir/$page.txt" "$textdir/$md"
        fi
    done
}

bookdir="$WORK/book"
function collectMarkdown()
{
    book=$bookName.md
    mkdir -p "$bookdir"
    bookfile="$bookdir/$book"
    for text in `ls -v $textdir/*.md`
    do
        #skip empty files...
        echo "processing "+$text
        echo "<div id=$text>" >> "$bookfile"
        cat $text >> "$bookfile"
        echo "</div>" >> "$bookfile"
    done
    echo "created $book"
}

function bookToEPUB()
{
    if ! [ -x "$(command -v pandoc)" ]; then
      sudo apt install -y pandoc
    fi
    epub="$bookdir/$bookName.epub"
    chapters=`ls -v $bookdir/*.md`
    echo "creating $epub"
    pandoc -o $epub $chapters
}

function bookToKindle()
{
  epub="$bookdir/$bookName.epub"
  kindle="$bookdir/$bookName.azw3"
  if ! [ -x "$(command -v ebook-convert)" ]; then
    echo "can't create kindle e-book: install 'CALIBRE' to enable kindle conversion."
  fi
  ebook-convert "$epub" "$kindle"
}