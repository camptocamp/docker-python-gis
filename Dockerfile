FROM ubuntu:18.04
LABEL maintainer "info@camptocamp.org"

COPY requirements.txt build.sh /tmp/
RUN /tmp/build.sh
