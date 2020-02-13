FROM ubuntu:18.04
LABEL maintainer "info@camptocamp.org"

RUN \
  apt-get update && \
  apt-get install --assume-yes --no-install-recommends librasterlite2-dev  && \
  apt-get clean && \
  rm --recursive --force /var/lib/apt/lists/*

COPY requirements.txt build.sh /tmp/
RUN /tmp/build.sh

# work around a bug in pkg-config breaking the installation of some pip packages
ENV PKG_CONFIG_ALLOW_SYSTEM_LIBS=OHYESPLEASE
