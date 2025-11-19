#!/bin/bash

cd /doc

if [ -n "$PROJECT" ]; then
  echo "Setting RENV_PATHS_LIBRARY for project: $PROJECT"
  export RENV_PATHS_LIBRARY="/root/.cache/R/renv/$PROJECT"
else
  echo "PROJECT environment variable is not set. Using $RENV_PATHS_LIBRARY."
fi

if [ $# -eq 0 ]; then
  R
else
  if [ "$1" = "index.Rmd" ]; then
    Rscript -e "renv::restore()"
    Rscript -e "bookdown::render_book('$1')"
  else
    Rscript -e "renv::restore()"
    Rscript -e "rmarkdown::render('$1',output_format = 'all')"
  fi
fi