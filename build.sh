#!/bin/bash
set -ex

GDAL_VERSION=$(sed -ne 's/GDAL==\(.*\)/\1/p' /tmp/requirements.txt)
NB_CPUS=`grep -c ^processor /proc/cpuinfo`

# install the python packages
apt update
apt install -y --no-install-recommends python3.6 python3-pip python3-dev python3-setuptools python3-wheel \
                                       libpython3.6 curl build-essential python3-pkgconfig gnupg
ln -s pip3 /usr/bin/pip
ln -s python3 /usr/bin/python

# install the packages needed to run GDAL
apt install -y --no-install-recommends libpq5 libexpat1 libkmlconvenience1 libkmlregionator1 libkmlxsd1 \
                                       libspatialite7 libopenjp2-7

# install the packages needed to build (will be removed at the end)
apt install -y --no-install-recommends libcurl4-openssl-dev libpq-dev libexpat1-dev libkml-dev libspatialite-dev \
                                       libopenjp2-7-dev

# download GDAL
curl http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz > /tmp/gdal.tar.gz
tar --extract --file=/tmp/gdal.tar.gz --directory=/tmp

# build GDAL
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
make -j${NB_CPUS}
make -j${NB_CPUS} install
cd /

# remove debug symbols
strip /usr/lib/libgdal.so.*.*.* /usr/bin/ogr* /usr/bin/gdal* || true

pip install --disable-pip-version-check --no-cache-dir -r /tmp/requirements.txt

# remove stuff that is not needed anymore
apt remove --purge -y libcurl4-openssl-dev libpq-dev libkml-dev libspatialite-dev libopenjp2-7-dev
apt autoremove --purge -y
apt clean
rm --force --recursive /tmp/* /var/lib/apt/lists/*

# test if we didn't remove too many packages
ogr2ogr --formats
gdalinfo --formats
