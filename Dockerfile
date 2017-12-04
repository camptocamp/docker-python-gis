FROM python:3.6-stretch
LABEL maintainer "info@camptocamp.org"

ENV GDAL_VERSION 2.2.3
RUN wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz --output-document=/tmp/gdal.tar.gz && \
    tar --extract --file=/tmp/gdal.tar.gz --directory=/tmp && \
    cd /tmp/gdal-${GDAL_VERSION} && \
    ./configure \
        --prefix=/usr \
        --with-python \
        --with-geos \
        --with-geotiff \
        --with-jpeg \
        --with-png \
        --with-expat \
        --with-libkml \
        --with-openjpeg \
        --with-pg \
        --with-curl \
        --with-spatialite \
        --disable-static && \
    make -j`grep -c ^processor /proc/cpuinfo` && \
    make install && \
    bash -c "strip /usr/lib/libgdal.so.*.*.* /usr/bin/ogr* /usr/bin/gdal* || true" &&  \
    pip install --disable-pip-version-check --no-cache-dir GDAL==${GDAL_VERSION} && \
    rm --force --recursive /tmp/gdal-${GDAL_VERSION} /tmp/gdal.tar.gz
