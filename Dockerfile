FROM rocker/tidyverse:4.0.3@sha256:6c228f305c6e1322e7259cd22d0bcfffb26b56fde08b4d6eb854405f7943d9da

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    fonts-ipaexfont \
    libgdal-dev \
    libudunits2-dev \
    zlib1g-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG GITHUB_PAT

RUN set -x && \
  echo "GITHUB_PAT=$GITHUB_PAT" >> /usr/local/lib/R/etc/Renviron

RUN set -x && \
  mkdir -p /home/rstudio/.local/share/renv/cache && \
  chown -R rstudio:rstudio /home/rstudio

RUN set -x && \
  install2.r --error --ncpus -1 --repos 'https://cran.microsoft.com/snapshot/2020-11-25/' \
    renv && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
