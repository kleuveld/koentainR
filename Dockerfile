FROM rocker/r-ver:4.4.2

# Default runtime UID/GID. Override with --build-arg APP_UID=... --build-arg APP_GID=...
ARG APP_UID=1000
ARG APP_GID=1000

# Install system dependencies and R packages as root
RUN /rocker_scripts/setup_R.sh https://packagemanager.posit.co/cran/__linux__/jammy/2025-07-31/
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_geospatial.sh
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Create directories and set permissions
# we set permissions as loose as possible as this thing runs one-off anyway
RUN mkdir -p /home/app /doc /renv/library \
  && chown -R ${APP_UID}:${APP_GID} /home/app /doc /renv \
  && chmod -R 777 /doc /renv /usr/local/lib/R/site-library


# Copy script
COPY ./files/rendermarkdown.sh /rendermarkdown.sh
RUN chmod 777 /rendermarkdown.sh

WORKDIR /doc


# Switch to app user
ENV HOME=/home/app
USER ${APP_UID}:${APP_GID}
ENV RENV_PATHS_LIBRARY=/renv/library
COPY renv.lock /doc/


# Install R packages as app user
RUN install2.r remotes
RUN Rscript -e "remotes::install_version('renv', version = '1.1.1')"



# Activate and initialize renv
RUN Rscript -e "renv::init(bare = TRUE)" \
    && Rscript -e "renv::activate()" \
    && Rscript -e "renv::restore(lockfile = '/doc/renv.lock', confirm = FALSE)"

ENTRYPOINT [ "/rendermarkdown.sh" ]