FROM python:3.6-jessie
LABEL maintainer "info@camptocamp.org"

RUN wget http://download.osgeo.org/gdal/2.2.2/gdal-2.2.2.tar.gz --output-document=/tmp/gdal.tar.gz && \
    tar --extract --file=/tmp/gdal.tar.gz --directory=/tmp && \
    cd /tmp/gdal-2.2.2 && \
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
    pip install --disable-pip-version-check --no-cache-dir GDAL==2.2.2 && \
    rm --force --recursive /tmp/gdal-2.2.2 /tmp/gdal.tar.gz
