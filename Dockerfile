FROM debian:buster AS base
LABEL maintainer "info@camptocamp.org"

RUN \
  apt-get update && \
  apt-get install --assume-yes --no-install-recommends python3 python3-dev curl build-essential \
    bash-completion && \
  apt-get clean && \
  rm --recursive --force /var/lib/apt/lists/*


FROM base AS builder

RUN \
    apt-get update && \
    apt-get install --assume-yes --no-install-recommends libcurl4-openssl-dev libpq-dev libkml-dev \
        libspatialite-dev libopenjp2-7-dev libspatialite-dev libwebp-dev librasterlite2-dev python3-pkgconfig && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/*

COPY requirements.txt /tmp/

RUN export GDAL_VERSION=$(sed -ne 's/GDAL==\(.*\)/\1/p' /tmp/requirements.txt) && \
    curl http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz > /tmp/gdal.tar.gz && \
    tar --extract --file=/tmp/gdal.tar.gz --directory=/tmp && \
    mv /tmp/gdal-${GDAL_VERSION} /tmp/gdal

WORKDIR /tmp/gdal

RUN ./configure \
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
        --with-openjpeg \
        --with-webp \
        --disable-static && \
    make -j$(grep -c ^processor /proc/cpuinfo)
RUN make -j$(grep -c ^processor /proc/cpuinfo) install

# Remove debug symbols
RUN strip /usr/lib/libgdal.so.*.*.* /usr/bin/ogr* /usr/bin/gdal* || true

FROM base AS runner

RUN \
    apt-get update && \
    apt-get install --assume-yes --no-install-recommends python3 python3-pip python3-dev python3-setuptools \
        python3-wheel libpq5 libexpat1 libkmlconvenience1 libkmlregionator1 libkmlxsd1 libspatialite7 \
        libopenjp2-7 libwebp6 librasterlite2-1 && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/*

COPY --from=builder /usr/bin/gdal2tiles.py /usr/bin/gdal_fillnodata.py /usr/bin/gdal_sieve.py \
    /usr/bin/epsg_tr.py /usr/bin/gdalcompare.py /usr/bin/gcps2wld.py /usr/bin/gdal_merge.py \
    /usr/bin/ogrmerge.py /usr/bin/gdal_auth.py /usr/bin/gdal_polygonize.py /usr/bin/gdal_pansharpen.py \
    /usr/bin/gdalmove.py /usr/bin/gdalimport.py /usr/bin/gdal_proximity.py /usr/bin/gdal_edit.py \
    /usr/bin/rgb2pct.py /usr/bin/esri2wkt.py /usr/bin/gdal_retile.py /usr/bin/gdal2xyz.py \
    /usr/bin/pct2rgb.py /usr/bin/mkgraticule.py /usr/bin/gdalchksum.py /usr/bin/gcps2vec.py \
    /usr/bin/gdal_calc.py /usr/bin/gdalident.py /usr/bin/gdal* /usr/bin/ogr* /usr/bin/

COPY --from=builder /usr/share/gdal /usr/share/

COPY --from=builder /usr/lib/libgdal* /usr/lib/gdalplugins /usr/lib/ogr* /usr/lib/

COPY --from=builder /usr/include/gdal* /usr/include/ogr* /usr/include/cpl_* /usr/include/gnm* \
    /usr/include/

COPY --from=builder /usr/etc/bash_completion.d/gdal-bash-completion.sh /usr/etc/bash_completion.d/

COPY requirements.txt /tmp/

RUN python3 -m pip install --disable-pip-version-check --no-cache-dir -r /tmp/requirements.txt

# Work around a bug in pkg-config breaking the installation of some pip packages
#ENV PKG_CONFIG_ALLOW_SYSTEM_LIBS=OHYESPLEASE


FROM runner as tests

# Test if we didn't remove too many packages
RUN ogr2ogr --formats
RUN gdalinfo --formats
RUN python3 -c 'import gdal'
RUN python3 -c 'import ogr'
