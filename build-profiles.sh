#!/bin/bash

echo Generating Dockerfile.wxp32-ie7 ...

BROWSER_VERSION=7
IE_INSTALL_URL=https://download.microsoft.com/download/3/8/8/38889DC1-848C-4BF2-8335-86C573AD86D9/IE7-WindowsXP-x86-enu.exe
IE_INSTALL_SHA256=bf5c325bbe3f4174869b2a8ff75f92833e7f7debe64777ed0faf293c7725cbef

cat Dockerfile.wxp32-ie6 \
  | sed -e 's!^ENV BROWSER_VERSION=.*$!ENV BROWSER_VERSION='"$BROWSER_VERSION"'!' \
        -e 's!^ARG IE_INSTALL_URL=.*$!ARG IE_INSTALL_URL='"$IE_INSTALL_URL"'!' \
        -e 's!^ARG IE_INSTALL_SHA256=.*$!ARG IE_INSTALL_SHA256='"$IE_INSTALL_SHA256"'!' \
  > Dockerfile.wxp32-ie7

################################################################################

echo Generating Dockerfile.wxp32-ie8 ...

BROWSER_VERSION=8
IE_INSTALL_URL=https://download.microsoft.com/download/3/8/C/38CE0ABB-01FD-4C0A-A569-BC5E82C34A17/IE8-WindowsXP-KB2936068-x86-ENU.exe
IE_INSTALL_SHA256=8bda23c78cdcd9d01c364a01c6d639dfb2d11550a5521b8a81c808c1a2b1824e

cat Dockerfile.wxp32-ie6 \
  | sed -e 's!^ENV BROWSER_VERSION=.*$!ENV BROWSER_VERSION='"$BROWSER_VERSION"'!' \
        -e 's!^ARG IE_INSTALL_URL=.*$!ARG IE_INSTALL_URL='"$IE_INSTALL_URL"'!' \
        -e 's!^ARG IE_INSTALL_SHA256=.*$!ARG IE_INSTALL_SHA256='"$IE_INSTALL_SHA256"'!' \
  > Dockerfile.wxp32-ie8

################################################################################

echo Generating Dockerfile.wxp64-ie6 ...

QEMU_VGA=std
WIN_ISO_FILE=en_win_xp_pro_x64_with_sp2_vl_X13-41611.iso
WIN_ISO_SHA256=ace108a116ed33ddbfd6b7e2c5f21bcef9b3ba777ca9a8052730138341a3d67d
WIN_ARCH=AMD64
VIRTIO_ARCH=2k3/amd64

cat Dockerfile.wxp32-ie6 \
  | sed -e 's!^ARG QEMU_VGA=.*$!ARG QEMU_VGA='"$QEMU_VGA"'!g' \
        -e 's!^ARG WIN_ISO_FILE=.*$!ARG WIN_ISO_FILE='"$WIN_ISO_FILE"'!' \
        -e 's!^ARG WIN_ISO_SHA256=.*$!ARG WIN_ISO_SHA256='"$WIN_ISO_SHA256"'!' \
        -e 's!^ARG WIN_ARCH=.*$!ARG WIN_ARCH='"$WIN_ARCH"'!' \
        -e 's!^ARG VIRTIO_ARCH=.*$!ARG VIRTIO_ARCH='"$VIRTIO_ARCH"'!' \
  > Dockerfile.wxp64-ie6

################################################################################

echo Generating Dockerfile.wxp64-ie6-64 ...

IE_DRIVER_URL=https://selenium-release.storage.googleapis.com/2.46/IEDriverServer_x64_2.46.0.zip
IE_DRIVER_SHA256=2463b0bcaa87ae7043cac107b62abd65efa673100888860ce81a6ee7fdc2e940

cat Dockerfile.wxp64-ie6 \
  | sed -e 's!^ARG IE_DRIVER_URL=.*$!ARG IE_DRIVER_URL='"$IE_DRIVER_URL"'!g' \
        -e 's!^ARG IE_DRIVER_SHA256=.*$!ARG IE_DRIVER_SHA256='"$IE_DRIVER_SHA256"'!' \
  > Dockerfile.wxp64-ie6-64

################################################################################

echo Generating Dockerfile.wxp64-ie7 ...

BROWSER_VERSION=7
IE_INSTALL_URL=https://download.microsoft.com/download/1/1/4/114d5b07-4dbc-42f3-96fa-2097e207d0af/IE7-WindowsServer2003-x64-enu.exe
IE_INSTALL_SHA256=1050f2620a2646ca007a473953ee2e6cba6f561ce88df34a681e7680a4a6d032

cat Dockerfile.wxp64-ie6 \
  | sed -e 's!^ENV BROWSER_VERSION=.*$!ENV BROWSER_VERSION='"$BROWSER_VERSION"'!' \
        -e 's!^ARG IE_INSTALL_URL=.*$!ARG IE_INSTALL_URL='"$IE_INSTALL_URL"'!' \
        -e 's!^ARG IE_INSTALL_SHA256=.*$!ARG IE_INSTALL_SHA256='"$IE_INSTALL_SHA256"'!' \
  > Dockerfile.wxp64-ie7

################################################################################

echo Generating Dockerfile.wxp64-ie7-64 ...

IE_DRIVER_URL=https://selenium-release.storage.googleapis.com/2.46/IEDriverServer_x64_2.46.0.zip
IE_DRIVER_SHA256=2463b0bcaa87ae7043cac107b62abd65efa673100888860ce81a6ee7fdc2e940

cat Dockerfile.wxp64-ie7 \
  | sed -e 's!^ARG IE_DRIVER_URL=.*$!ARG IE_DRIVER_URL='"$IE_DRIVER_URL"'!g' \
        -e 's!^ARG IE_DRIVER_SHA256=.*$!ARG IE_DRIVER_SHA256='"$IE_DRIVER_SHA256"'!' \
  > Dockerfile.wxp64-ie7-64

################################################################################

echo Generating Dockerfile.wxp64-ie8 ...

BROWSER_VERSION=8
IE_INSTALL_URL=https://download.microsoft.com/download/7/5/4/754D6601-662D-4E39-9788-6F90D8E5C097/IE8-WindowsServer2003-x64-ENU.exe
IE_INSTALL_SHA256=bcff753e92ceabf31cfefaa6def146335c7cb27a50b95cd4f4658a0c3326f499

cat Dockerfile.wxp64-ie6 \
  | sed -e 's!^ENV BROWSER_VERSION=.*$!ENV BROWSER_VERSION='"$BROWSER_VERSION"'!' \
        -e 's!^ARG IE_INSTALL_URL=.*$!ARG IE_INSTALL_URL='"$IE_INSTALL_URL"'!' \
        -e 's!^ARG IE_INSTALL_SHA256=.*$!ARG IE_INSTALL_SHA256='"$IE_INSTALL_SHA256"'!' \
  > Dockerfile.wxp64-ie8

################################################################################

echo Generating Dockerfile.wxp64-ie8-64 ...

IE_DRIVER_URL=https://selenium-release.storage.googleapis.com/2.46/IEDriverServer_x64_2.46.0.zip
IE_DRIVER_SHA256=2463b0bcaa87ae7043cac107b62abd65efa673100888860ce81a6ee7fdc2e940

cat Dockerfile.wxp64-ie8 \
  | sed -e 's!^ARG IE_DRIVER_URL=.*$!ARG IE_DRIVER_URL='"$IE_DRIVER_URL"'!g' \
        -e 's!^ARG IE_DRIVER_SHA256=.*$!ARG IE_DRIVER_SHA256='"$IE_DRIVER_SHA256"'!' \
  > Dockerfile.wxp64-ie8-64
