FROM ubuntu:22.04

ARG LENSTOOL_VERSION=8.0.4

# CANFAR 
ADD nsswitch.conf /etc/

# dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes --quiet
RUN apt-get install --yes \
    wget build-essential\
    automake libtool autoconf gfortran \
    pgplot5 libgsl-dev libx11-dev libzmq5-dev libcfitsio-dev wcslib-dev

# build lenstool
ENV LENSTOOL_VERSION=${LENSTOOL_VERSION}
WORKDIR /opt
RUN wget https://git-cral.univ-lyon1.fr/lenstool/lenstool/-/archive/${LENSTOOL_VERSION}/lenstool-${LENSTOOL_VERSION}.tar.gz && \
    tar xf lenstool-${LENSTOOL_VERSION}.tar.gz

WORKDIR /opt/lenstool-${LENSTOOL_VERSION}

# hack to patch bugs on-the-fly
RUN sed \
    -e 's/-finit-local-zero/-finit-local-zero -fallow-argument-mismatch/' \
    -e 's/-lX11/-lX11 @PGPLOT_LIB@/g' \
    -e 's|@top_builddir@/src/liblenstool.la|@top_builddir@/src/liblenstool.la @top_builddir@/liblt/liblt.la|g' \
    -i utils/Makefile.am && \
    autoreconf -vif

ENV LENSTOOL_DIR=/opt/lenstool-${LENSTOOL_VERSION}
ENV PATH=${PATH}:${LENSTOOL_DIR}/src:${LENSTOOL_DIR}/perl:${LENSTOOL_DIR}/utils

RUN ./configure \
    --enable-pgplot \
    --with-wcslib-include-path="/usr/include/wcslib"

RUN make -j2 && make table
