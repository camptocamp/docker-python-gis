FROM python:3.6-stretch
LABEL maintainer "info@camptocamp.org"

COPY requirements.txt build.sh /tmp/
RUN /tmp/build.sh
