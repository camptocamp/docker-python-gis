#!/bin/bash
set -e
GDAL_VERSION=$(sed -ne 's/GDAL==\(.*\)/\1/p' /tmp/requirements.txt)

wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz --output-document=/tmp/gdal.tar.gz
tar --extract --file=/tmp/gdal.tar.gz --directory=/tmp

cd /tmp/gdal-${GDAL_VERSION}
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
    --disable-static

make -j`grep -c ^processor /proc/cpuinfo`
make install

strip /usr/lib/libgdal.so.*.*.* /usr/bin/ogr* /usr/bin/gdal* || true

export CPLUS_INCLUDE_PATH=$PWD/port
pip install --disable-pip-version-check --no-cache-dir -r /tmp/requirements.txt
rm --force --recursive /tmp/gdal-${GDAL_VERSION} /tmp/gdal.tar.gz /tmp/requirements.txt /tmp/build.sh
