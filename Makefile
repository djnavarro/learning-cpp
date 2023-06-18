all: bin/helloworld bin/helloworld-using bin/typecasting docs/index.html docs/chapter-01.html

bin/helloworld: src/helloworld.cpp
	mkdir -p ./bin
	clang++ --std=c++20 src/helloworld.cpp -o bin/helloworld

bin/helloworld-using: src/helloworld-using.cpp
	mkdir -p ./bin
	clang++ --std=c++20 src/helloworld-using.cpp -o bin/helloworld-using

bin/typecasting: src/typecasting.cpp
	mkdir -p ./bin
	clang++ --std=c++20 src/typecasting.cpp -o bin/typecasting

docs/index.html: notes/index.md pandoc/template.html
	mkdir -p ./docs
	pandoc ./notes/index.md \
	--standalone \
	--template=./pandoc/template.html \
    --output=./docs/index.html

docs/chapter-01.html: notes/chapter-01.md pandoc/template.html
	mkdir -p ./docs
	pandoc ./notes/chapter-01.md \
	--standalone \
	--template=./pandoc/template.html \
    --output=./docs/chapter-01.html

