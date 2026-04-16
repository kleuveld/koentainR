#!/bin/bash

cd /doc

# multiple projects arent currently supported.
# if [ -n "$PROJECT" ]; then
#   echo "Setting RENV_PATHS_LIBRARY for project: $PROJECT"
#   CACHE_HOME="${HOME:-/tmp}"
#   export RENV_PATHS_LIBRARY="$CACHE_HOME/.cache/R/renv/$PROJECT"
#   mkdir -p "$RENV_PATHS_LIBRARY"
# else
#   echo "PROJECT environment variable is not set. Using $RENV_PATHS_LIBRARY."
# fi

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