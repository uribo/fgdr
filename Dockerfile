FROM rocker/tidyverse:3.6.2

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libgdal-dev \
    libudunits2-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG GITHUB_PAT

RUN set -x && \
  echo "GITHUB_PAT=$GITHUB_PAT" >> /usr/local/lib/R/etc/Renviron

RUN set -x && \
  install2.r --error \
    ensurer \
    jpmesh \
    mapview \
    raster \
    rgdal \
    reprex \
    roxygen2 \
    sf \
    stars \
    usethis \
    zeallot && \
  installGithub.r \
    "dantonnoriega/xmltools" && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
