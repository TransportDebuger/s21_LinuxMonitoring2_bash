#!/bin/bash

wget https://tar.goaccess.io/goaccess-1.9.3.tar.gz
tar -xzvf goaccess-1.9.3.tar.gz
cd goaccess-1.9.3/
./configure --enable-utf8 --enable-geoip=mmdb
make
make install