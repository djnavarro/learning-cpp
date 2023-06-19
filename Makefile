cpp_src := $(wildcard src/*.cpp)
cpp_out := $(patsubst src/%.cpp, bin/%, $(cpp_src))

pandoc_src := $(wildcard notes/*.md)
pandoc_out := $(patsubst notes/%.md, docs/%.html, $(pandoc_src))

all: dirs $(cpp_out) $(pandoc_out) docs/style.css docs/.nojekyll docs/CNAME

dirs:
	@mkdir -p ./bin
	@mkdir -p ./docs

bin/%: src/%.cpp
	clang++ --std=c++20 $< -o $@

docs/style.css: pandoc/style.css
	cp pandoc/style.css docs/style.css

docs/.nojekyll:
	touch docs/.nojekyll

docs/CNAME:
	echo "learning-cpp.djnavarro.net" > docs/CNAME

docs/%.html: notes/%.md
	pandoc $< -o $@ --standalone --template=./pandoc/template.html --mathjax --toc --toc-depth 2

clean:
	rm -rf docs
	rm -rf bin

