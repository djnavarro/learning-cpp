My notes-to-self while working through *Professional C++ (5th edition)* by Marc Gregoire

Directory structure: 

- `src`: C++ source code, where each chapter is a subfolder
- `notes`: Markdown files, where each chapter is one document
- `docs`: HTML output and other files needed to publish the site 
- `static`: Static files that are copied directly to `docs`
- `build`: Source files etc used when building HTML from markdown

Top-level files have their usual meaning:

- `Makefile`: Handles C++ compilation and builds docs
- `pyproject.toml`: Specifies Python dependencies (...but it's just [codebraid](https://github.com/gpoore/codebraid))
- `.gitignore`: Avoid committing unwanted things, as always
- `LICENCE.md`: Does what it says on the tin
- `README.md`: This file, obvs

Files/directories not committed:

- `bin`: Executables built from C++ source, one subfolder per chapter
- `_codebraid`: Code execution results, when building markdown to HTML
- `poetry.lock`: Lock file for the poetry project specified in `pyproject.toml`

Note-to-self regarding poetry:

Seems like it's easy to run afoul of the [keyring issue](https://github.com/python-poetry/poetry/issues/1917). When trying to install dependencies on a fresh machine using `poetry install`, it stalls at the "Resolving dependencies" step and then fails. The fix appears to be a mildly annoying hack where you install the keyring package and then explicitly disable it. Anyways, solution appears to be this:

```
poetry run python -m pip install keyring
poetry run python -m keyring --disable
```

It's not pretty, but once that's done poetry seems to work properly. Sigh.
