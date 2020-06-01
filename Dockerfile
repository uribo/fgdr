FROM rocker/tidyverse:4.0.0

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    fonts-ipaexfont \
    libgdal-dev \
    libudunits2-dev && \
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
  install2.r --error --ncpus -1 --repos 'http://mran.revolutionanalytics.com/snapshot/2020-05-30' \
    devtools \
    ensurer \
    jpmesh \
    mapview \
    reprex \
    stars \
    usethis \
    zeallot \
    renv && \
  installGithub.r \
    dantonnoriega/xmltools && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
