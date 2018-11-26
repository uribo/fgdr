FROM rocker/tidyverse:3.5.1

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libgdal-dev \
    libudunits2-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN set -x && \
  install2.r --error \
    mapview \
    reprex \
    sf \
    usethis && \
  installGithub.r \
    "dantonnoriega/xmltools" && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
