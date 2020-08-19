FROM rocker/tidyverse:4.0.2@sha256:cbc4ee809d594f0f6765be1d0fa046f48dfcda7340b5830473dd28fc71940c3c

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    fonts-ipaexfont \
    libgdal-dev \
    libudunits2-dev \
    zlib1g-dev && \
  apt-get install -y \
    r-cran-sf \
    r-cran-raster \
    r-cran-rgdal \
    r-cran-roxygen2 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG GITHUB_PAT

RUN set -x && \
  echo "GITHUB_PAT=$GITHUB_PAT" >> /usr/local/lib/R/etc/Renviron

RUN set -x && \
  install2.r --error --ncpus -1 --repos 'https://mran.revolutionanalytics.com/snapshot/2020-08-18' \
    data.table \
    devtools \
    ensurer \
    jpmesh \
    mapview \
    reprex \
    stars \
    terra \
    usethis \
    zeallot \
    renv && \
  installGithub.r \
    dantonnoriega/xmltools && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
