FROM rocker/r-ver:4.4.2

# ensure versions for r packages are always the same
RUN /rocker_scripts/setup_R.sh https://packagemanager.posit.co/cran/__linux__/jammy/2025-07-31/

#run pandoc install script
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_geospatial.sh


#install R packages
RUN install2.r  \
  remotes

RUN Rscript -e "remotes::install_version('renv', version = '1.1.1')"

#COPY .cache/R/renv /root/.cache/R/renv

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /doc
COPY ./files/rendermarkdown.sh /
RUN chmod 755 /rendermarkdown.sh 

#COPY lockfiles /tmp/lockfiles
COPY renv.lock /doc/

RUN Rscript -e "renv::activate()"

COPY ./files/ggthemewur_0.1.0.tar.gz /

ENV RENV_PATHS_LIBRARY=/renv/library

# Initialize renv in the /doc folder and prepopulate the cache
RUN Rscript -e "renv::init(bare = TRUE)" \
    && Rscript -e "renv::activate()" \
    && Rscript -e "renv::restore(lockfile = '/doc/renv.lock', confirm = FALSE)" \
    && Rscript -e "install.packages('/ggthemewur_0.1.0.tar.gz')"


ENTRYPOINT [ "/rendermarkdown.sh" ]