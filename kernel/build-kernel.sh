#!/bin/bash

# build-kernel.sh
#
# This script builds the Porteus kernel.
#
# Author: Ben the Pyrate <dragonwisard@gmail.com>

VERSION=2.6.38.8
AUFS_PATCH=aufs2.1-38.patch

# Cleanup
rm -rf linux-$VERSION

# Extract
tar xvf linux-$VERSION.tar.?z*

cd linux-$VERSION

# Patch
patch -p1 < ../$AUFS_PATCH

# Configure
cp ../porteus.config .config
#make oldconfig
#make menuconfig

# Build
make -j4

cd ..

