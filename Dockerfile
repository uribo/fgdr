FROM rocker/tidyverse:4.0.2@sha256:7053555372caf65acd6e45cbe1ef80656b182c5da6c4e1a4540dbcce879eb719

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
  install2.r --error --ncpus -1 --repos 'https://mran.revolutionanalytics.com/snapshot/2020-09-29' \
    renv && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
