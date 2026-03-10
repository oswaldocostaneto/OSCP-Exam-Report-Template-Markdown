FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    OSERT_HOME=/opt/osert \
    OSERT_DATA_DIR=/data

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ruby \
      pandoc \
      texlive-xetex \
      texlive-latex-recommended \
      texlive-latex-extra \
      texlive-fonts-recommended \
      texlive-fonts-extra \
      lmodern \
      fonts-lmodern \
      p7zip-full \
      ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR ${OSERT_HOME}

# Bundle the project itself so the container is self-contained.
COPY osert.rb ${OSERT_HOME}/osert.rb
COPY src ${OSERT_HOME}/src
COPY filters ${OSERT_HOME}/filters

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
 && mkdir -p "${OSERT_DATA_DIR}"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
