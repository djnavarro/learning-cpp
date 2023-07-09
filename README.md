My notes while working through *Professional C++ (5th edition)* by Marc Gregoire

Directory structure: 

- C++ source code in `src` folder (each chapter is a subfolder)
- Markdown is the `notes` folder
- HTML output in `docs` folder
- Static files copied directly to `docs` are in `static`
- Files used to build HTML notes from markdown are in `build`

Directories hidden by `.gitignore`

- Binary files are written to `bin` (one subfolder per chapter)
- Code execution results are in `_codebraid`

Top-level files all have their usual meaning:

- `Makefile` handles C++ compilation and builds docs
- `pyproject.toml` specifies Python dependencies (just codebraid)
- `poetry.lock` is the lockfile for the Python environment
- `.gitignore` to avoide committing silly things, as usual
- `LICENCE.md` does what it says
- `README.md` is this file, obvs

