# Translate Books

## Calibre
Craft a single HTML file with all contents:
1. Edit your EPUB using Calibre Ebook Editor
2. Select all HTML content pages -> Right Click -> Merge selected Text Files
3. Right click on the merged file -> Export XYZ.html -> Store it on your disk

## DeepL

1. DeepL accepts *.html but no *.xhtml files, so rename your exported file if necessary
2. Get a DeepL API key; developers get 500K characters per month for free
3. Use an AxonIvyDesigner, download the deepl-demo
4. Take the FileUploadAdvanced (keeping HTML tags intact) and upload your file
5. The resulting file will be stored under `Designer/system/work/designer/...`
6. Rename it from translated.pdf to mybook.html

## Finalize

1. Open the Calibre Ebook Editor again
2. Replace the main HTML file with your translated variant
3. Consider to split the book again:

    - right click into the content file
    - select "Split at multiple locations"
    -  use the wizard to define your splitting (usually a header like H2)
4. Splitting page-break before each chapter

    - Open the main stylesheet
    - Define a style for your main header used for chapters
    - Add `page-break-before: always`

    ```css
    h2: {
        page-break-before: always
    }
    ```
