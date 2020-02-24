#!/bin/bash

ts=$(date +%s)
WORK=/tmp/booksAlive$ts
if [ ! -z "$1" ];then
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
    if [ ! -z "$1" ]
      then
        LANG=$1
    fi
    # recognize fractured german text in raw images:
    if ! [ -x "$(command -v tesseract)" ]; then
      sudo apt install -y tesseract-ocr tesseract-ocr-deu-frak
    fi
    mkdir -p "$textdir"
    echo "scanning $pagesdir"
    for img in `ls -v $pagesdir/*.png`
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
    for text in `ls -v $textdir/*/*.md`
    do
        #skip empty files...
        echo "processing "+$text
        #echo "<div id=\"$text\">" >> "$bookfile"
        cat $text >> "$bookfile"
        #echo "</div>" >> "$bookfile"
    done
    echo "created $book"
}

function transformMarkdown()
{
    MD_FIND='*.md'
    if [ ! -z "$1" ]; then
        MD_FIND=$1
    fi
    
    tdir="$DIR/trans"
    rm -r -v "$tdir"
    mkdir -p "$tdir"
    rm "$bookfile"

    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd "$textdir"
    for text in `ls -v ${MD_FIND}`; do
        echo "processing "$text

        parent=$(dirname "$text")
        mkdir -p "$tdir/$parent"
        target="$tdir/$text"

        file=$(basename $text)
        cleaned=$(find "$DIR/clean" -name "$file")
        if ! [ -z "$cleaned" ]; then
            text="$cleaned" #prefer local modified to generated
        fi
        $(improveMd "${text}" >> "$target")
    done
    cd "$DIR"
}

function improveMd()
{
    textIn="$1"
    # sed1-3: fix frequent false positives from OCR
    # sed4: remove hyphens at the end of the a line
    # sed5: mark titles with a 'pos' style
    # sed6: remove section brakes by wrong detected white spaces
    cat "$textIn" \
        | sed ':a;N;$!ba;s/-\n//g' \
        | sed -E ':a;N;$!ba;s/([a-z,])\n\n([a-z])/\1 \2/g'
}

function bookToEPUB()
{
    MD_FIND='trans/*.md'
    if [ ! -z "$1" ]; then
        MD_FIND=$1
    fi

    if ! [ -x "$(command -v pandoc)" ]; then
      sudo apt install -y pandoc
    fi
    pandoc \
     --epub-chapter-level=2 \
     --epub-stylesheet="$WORK/style.css" \
     -f markdown -o "$bookdir/$bookName.epub" \
     "$WORK/meta.md" \
     $(ls -v ${MD_FIND})
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