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
    # recognize fractured german text in raw images:
    if ! [ -x "$(command -v tesseract)" ]; then
      sudo apt install -y tessseract-ocr tesseract-ocr-deu-frak
    fi
    mkdir -p "$textdir"
    for img in `ls -v $pagesdir/page*.png`
    do
        png=`basename $img`
        page=${png:0:-4} #no-file-ext
        md=$page.md
        if ! [ -f "$textdir/$md" ]; then        
            echo "OCR on $img"
            tesseract $img $textdir/$page -l deu_frak
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

function pageToPDF()
{
    #pdf with original image + revised OCR text
    text="$1"
    pDir="$2"

    md=`basename $text`
    page=${md:0:-3}
    no=${page:5:3}
    
    #img
    imgPdf="$pDir/img/$page.pdf"
    if ! [ -f "$imgPdf" ]; then
        echo "extracting $imgPdf"
        pdfseparate -f $no -l $no $pdf $imgPdf
    fi

    #txt
    txtPdf="$pDir/txt/$page.pdf"
    if ! [ -f "$txtPdf" ]; then
        echo "creating $txtPdf"
        pandoc $text --latex-engine=xelatex -o $txtPdf
    fi

    #merge
    joinPdf="$pDir/join/$page.pdf"
    if ! [ -f "$joinPdf" ]; then
        echo "creating $joinPdf"
        pdfunite $imgPdf $txtPdf $joinPdf
    fi
}

pdfDir="$WORK/pdf"
function pagesToPDF()
{
    container=""
    if [ ! -z "$1" ]
      then
        container=$1
    fi
    echo $container

    # latex deps
    if ! [ -x "$(command -v xetex)" ]; then
      sudo apt install -y texlive-xetex texlive-fonts-recommended
    fi

    mkdir -p "$pdfDir"
    containerDir="$pdfDir/$container"
    mkdir -p "$containerDir"
    mkdir -p "$containerDir/img"
    mkdir -p "$containerDir/txt"
    mkdir -p "$containerDir/join"

    echo "pages to PDF: $containerDir"
    for text in `ls -v $textdir/$container/*.md`
    do
        pageToPDF "$text" "$containerDir"
    done
    
    # merge pages
    pages=`ls -v $containerDir/join/*.pdf`
    pdfContainer="$containerDir.pdf"
    echo "creating $pdfContainer"
    pdfunite $pages $pdfContainer
}

function bookToPDF()
{
    mkdir -p "$bookdir"
    pdfBook="$bookdir/$bookName.pdf"
    for chapter in `ls -v $textdir/*/ -d`
    do
        chapter=`basename $chapter`
        pagesToPDF $chapter
    done

    parts=`ls -v $pdfDir/*.pdf`
    echo "creating final $pdfBook"
    pdfunite $parts $pdfBook
}
