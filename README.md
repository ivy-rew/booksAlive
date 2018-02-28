# Books alive
Restore and conservate great pieces of literature

## Restore german books with fractured fonts
Google books contains some books that are no longer available anywhere else. Tough it might be great literature that had even been popular decades ago. But unfortunately google books didn't get the content of a book correctly and produced waste E-Books with many wrong recognized characters.

### Sample
The book "Peterli am Lift" from "Niklaus Bolt" has been scanned by google. But the results are poor:
[PDF https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.pdf]
[EPUB https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.epub]

### Conversion Scripts
We provide script to get better results. They should work on a debian based operating system such as Ubuntu.
```
wget https://archive.org/download/peterliamlift00boltgoog/peterliamlift00boltgoog.pdf
./imagesPdf2Text.sh peterliamlift00boltgoog.pdf
```
