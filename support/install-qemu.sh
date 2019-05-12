#!/bin/sh

# Build and install QEMU for x86_64 on RHEL-like distro (including Amazon Linux).

set -x
set -e

QEMU_VERSION=v4.0.0
QEMU_COMMIT_HASH=218faba4da90336c31f771ebbdfa9ae8dea47d50

yum install -y git gcc make bison flex
yum install -y glib2 zlib pixman libaio
yum install -y glib2-devel zlib-devel pixman-devel libaio-devel

git clone https://github.com/qemu/qemu.git
cd qemu
[ $(git rev-parse $QEMU_VERSION) = $QEMU_COMMIT_HASH ]
git checkout $QEMU_VERSION
mkdir build
cd build
../configure \
  --target-list=x86_64-softmmu \
  --enable-linux-aio
make
make install

rm -rf qemu

yum remove -y git gcc make bison flex
yum remove -y glib2-devel zlib-devel pixman-devel libaio-devel
yum autoremove -y
