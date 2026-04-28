FROM rocker/r-ver:4.4.2

# Default runtime UID/GID. Override with --build-arg APP_UID=... --build-arg APP_GID=...
ARG APP_UID=1000
ARG APP_GID=1000

# Install system dependencies and R packages as root
RUN /rocker_scripts/setup_R.sh https://packagemanager.posit.co/cran/__linux__/jammy/2026-04-21/
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_geospatial.sh
RUN apt-get update && apt-get install -y git libtiff-dev && rm -rf /var/lib/apt/lists/* \

# httpgd needs libtiff 5, but this only installs 6:
# Workaround: symlink libtiff.so.6 to libtiff.so.5 
  && if [ -e /usr/lib/x86_64-linux-gnu/libtiff.so.6 ] && [ ! -e /usr/lib/x86_64-linux-gnu/libtiff.so.5 ]; then \
    ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.6 /usr/lib/x86_64-linux-gnu/libtiff.so.5; \
  fi \
  # Workaround: symlink libtiffxx.so.6 to libtiffxx.so.5 if needed
  && if [ -e /usr/lib/x86_64-linux-gnu/libtiffxx.so.6 ] && [ ! -e /usr/lib/x86_64-linux-gnu/libtiffxx.so.5 ]; then \
    ln -s /usr/lib/x86_64-linux-gnu/libtiffxx.so.6 /usr/lib/x86_64-linux-gnu/libtiffxx.so.5; \
  fi

# Ensure UID/GID have passwd/group entries so tools like git can resolve names
RUN if ! getent group "${APP_GID}" >/dev/null; then groupadd --gid "${APP_GID}" koentainR; fi \
  && if ! getent passwd "${APP_UID}" >/dev/null; then useradd --uid "${APP_UID}" --gid "${APP_GID}" --home-dir /home/koentainR --create-home --shell /bin/bash koentainR; fi

# Create directories and set permissions
# we set permissions as loose as possible as this thing runs one-off anyway
RUN mkdir -p /home/koentainR /doc /renv/library \
  && chown -R ${APP_UID}:${APP_GID} /home/koentainR /doc /renv \
  && chmod -R 777 /doc /renv /usr/local/lib/R/site-library


# Copy script
COPY ./files/rendermarkdown.sh /rendermarkdown.sh
RUN chmod 777 /rendermarkdown.sh

WORKDIR /doc


# Switch to koentainR user
ENV HOME=/home/koentainR
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