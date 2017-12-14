FROM python:3.5
LABEL maintainer "info@camptocamp.org"

COPY requirements.txt build.sh /tmp/
RUN /tmp/build.sh
