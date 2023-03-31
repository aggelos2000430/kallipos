#!/bin/sh

rm -rf "./html"

mkdir ./html

echo -e "${RED}Calculating dependencies${NC}"
pandoc text/pre.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > html/2pre.html
pandoc text/intro.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > html/3intro.html

for filename in text/ch*.txt; do
   [ -e "$filename" ] || continue
   pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=mylua.lua --to markdown| pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure-pollen.lua --to markdown  | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to html > html/"$(basename "$filename" .txt).html"
done

pandoc text/web.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > html/zweb.html
pandoc text/bio.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > html/zzbio.html

for filename in text/apx*.txt; do
   [ -e "$filename" ] || continue
   pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure-pollen.lua --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to html > html/"z$(basename "$filename" .txt).html"
done

echo -e "Merging html files into book.html"
pandoc --quiet -s html/*.html -o index.html --metadata title="Ο Προγραμματισμός της Διάδρασης"
mv ./index.html ./index.html.pp
sed -i '1s/^/#lang pollen\n/' ./index.html.pp
raco pollen render ./index.html.pp
