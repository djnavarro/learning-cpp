all: bin/helloworld bin/helloworld-using bin/typecasting docs/index.html docs/chapter-01.html docs/style.css

bin/helloworld: src/helloworld.cpp
	mkdir -p ./bin
	clang++ --std=c++20 src/helloworld.cpp -o bin/helloworld

bin/helloworld-using: src/helloworld-using.cpp
	mkdir -p ./bin
	clang++ --std=c++20 src/helloworld-using.cpp -o bin/helloworld-using

bin/typecasting: src/typecasting.cpp
	mkdir -p ./bin
	clang++ --std=c++20 src/typecasting.cpp -o bin/typecasting

docs/style.css: pandoc/style.css
	mkdir -p ./docs
	cp pandoc/style.css docs/style.css

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

clean:
	rm -rf docs
	rm -rf bin

