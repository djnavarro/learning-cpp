mkdir -p ./docs
pandoc ./source/index.md \
    --standalone \
    --template=./template/template.html \
    --output=./docs/index.html

mkdir -p ./docs/01
pandoc ./source/01/index.md \
    --standalone \
    --template=./template/template.html \
    --output=./docs/01/index.html
