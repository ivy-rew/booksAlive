# Books alive
Restore and conservate great pieces of literature

## Restore german books with fractured fonts
Google books contains some books that are no longer available anywhere else. Though it might be great literature that had already been popular decades ago.

Unfortunately the used aproach to detect written text on the scanned books seems to have been totally unaware of old german fractured fonts. Therefore available textual representations do not contain much more than a weird mix of letters enricht with unrecognizeable characters.

### Sample
The book "Peterli am Lift" from "Niklaus Bolt" has been scanned by google. While the scanned [PDF](https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.pdf) is of good quality, the generated textual representations, such as the [EPUB](https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.epub), are poor.

More ?
- https://archive.org/details/smmtlichewerke01stilgoog/page/n1



### Conversion Scripts
We provide script to get better results. They should work on a debian based operating system such as Ubuntu.
```
wget https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.pdf
./imagesPdf2Text.sh peterliamlift00boltgoog.pdf
```
