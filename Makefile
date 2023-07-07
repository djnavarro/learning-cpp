cpp := $(patsubst src/01/%.cpp, bin/01/%, $(wildcard src/01/*.cpp))
cpp += $(patsubst src/02/%.cpp, bin/02/%, $(wildcard src/02/*.cpp))
cpp += $(patsubst src/03/%.cpp, bin/03/%, $(wildcard src/03/*.cpp))
notes := $(patsubst notes/%.md, docs/%.html, $(wildcard notes/*.md))
static := docs/.nojekyll docs/CNAME docs/style.css

.PHONY: dirs clean
all: dirs $(cpp) $(static) $(notes)

dirs:
	@mkdir -p ./bin
	@mkdir -p ./bin/01
	@mkdir -p ./bin/02
	@mkdir -p ./bin/03
	@mkdir -p ./docs

$(cpp): bin/%: src/%.cpp
	@echo "[compiling]" $<
	@clang++-15 --std=c++20 $< -o $@

$(static): docs/%: static/%
	@echo "[copying]" $< 
	@cp $< $@

$(notes): docs/%.html: notes/%.md
	@echo "[rendering]" $<
	@pandoc $< -o $@ --template=./pandoc/template.html \
		--standalone --mathjax --toc --toc-depth 2

clean:
	@echo "[deleting] docs"
	@echo "[deleting] bin"
	@rm -rf docs
	@rm -rf bin

