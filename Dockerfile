FROM python:3.6-jessie
LABEL maintainer "info@camptocamp.org"

RUN \
  apt-get update && \
  apt-get install --assume-yes --no-install-recommends librasterlite2-dev  && \
  apt-get clean && \
  rm --recursive --force /var/lib/apt/lists/*

COPY requirements.txt build.sh /tmp/
RUN /tmp/build.sh
