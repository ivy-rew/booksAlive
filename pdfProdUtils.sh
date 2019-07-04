#!/bin/bash

WORK=/tmp/booksAlive$ts
if [ ! -z "$1" ]
  then
    WORK=$1
fi

textdir="$WORK/text"

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
    pdfYaml="$WORK/pdf-meta.yaml"
    if ! [ -f "$pdfYaml" ]; then
      pdfYaml=""
    fi
    txtPdf="$pDir/txt/$page.pdf"
    if ! [ -f "$txtPdf" ]; then
        echo "creating $txtPdf"
        pandoc $text $pdfYaml --latex-engine=xelatex -o $txtPdf
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
    pdfContainer="$containerDir.united.pdf"
    if ! [ -f "$pdfContainer" ]; then
        echo "creating $pdfContainer"
        pdfunite $pages $pdfContainer
    fi
}

function dirToPdf()
{
    chapDir=$1
    echo "dirToPdf:$chapDir"
    for chapter in `ls -v $chapDir/*/ -d`
    do
        chapter=`basename $chapter`
        echo $chapter
        pagesToPDF $chapter
        #sub-chaps
        dirToPdf $chapDir/$chapter
    done
}

bookdir="$WORK/book"
function bookToPDF()
{
    mkdir -p "$bookdir"
    pdfBook="$bookdir/$bookName.pdf"
    dirToPdf $textdir

    parts=`ls -v $pdfDir/*united.pdf`
    echo "creating final $pdfBook"
    pdfunite $parts $pdfBook
}
