FROM ubuntu:18.04
LABEL maintainer "info@camptocamp.org"

COPY requirements.txt build.sh /tmp/
RUN /tmp/build.sh

# work around a bug in pkg-config breaking the installation of some pip packages
ENV PKG_CONFIG_ALLOW_SYSTEM_LIBS=OHYESPLEASE
