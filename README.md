# Books alive
Restore and conservate great pieces of literature

## Restore german books with fractured fonts
Google books contains some books that are no longer available anywhere else. Though it might be great literature that had already been popular decades ago.

Unfortunately the used aproach to detect written text on the scanned books seems to have been totally unaware of old german fractured fonts. Therefore available textual representations do not contain much more than a weird mix of letters enriched with unrecognizeable characters.

### Sample
The book "Peterli am Lift" from "Niklaus Bolt" has been scanned by google. While the scanned [PDF](https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.pdf) is of good quality, the generated textual representations, such as the [EPUB](https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.epub), are poor.

More ?
- https://archive.org/details/smmtlichewerke01stilgoog/page/n1



### Conversion Scripts
Here's a script that hoists the treasure confined within this digital PDF images.

The script relies on popular PDF tooling (poppler) and an OCR scanner (tesseract) with its extensions for german fractures. This set of free available software is able to bring the classic to life.

Scripts were crafted and designed to run on a debian based operating system such as Ubuntu (tested with Linux Mint 18).
```
wget https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.pdf
./revealLetters.sh peterliamlift00boltgoog.pdf
```
