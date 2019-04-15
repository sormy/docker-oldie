FROM debian:buster

LABEL maintainer="art.sormy@gmail.com"

# Build parameters.
ARG PRODUCT_KEY
ARG IE_VERSION=6
ARG QEMU_VGA=cirrus
ARG SCREEN_WIDTH=1024
ARG SCREEN_HEIGHT=768
ARG COLOR_DEPTH=24
ARG REFRESH_RATE=60

# Runtime parameters.
ENV SELENIUM_PORT=5555
ENV SELENIUM_HUB=
ENV VNC_PORT=5900
ENV QEMU_RAM=512
ENV QEMU_VGA=${QEMU_VGA}

# Verify build arguments.
RUN [ -n "$PRODUCT_KEY" ]
RUN [ "$IE_VERSION" = 6 ] || [ "$IE_VERSION" = 7 ] || [ "$IE_VERSION" = 8 ]

# Create and set working directory.
WORKDIR /opt/qemu

# Add required for build files into image.
ADD files/* /opt/qemu/
ADD support/* /opt/qemu/

# Make added shell scripts executable.
RUN chmod +x /opt/qemu/*.sh

# Install runtime and build-time dependencies.
RUN apt-get update \
    && apt-get install -y qemu-kvm samba bc kmod \
    && apt-get install -y wget genisoimage p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# QEMU 2.8 is consistently crashing inside Docker container.
RUN [ "$(qemu-system-x86_64 -version | head -n 1 \
        | sed 's/^.*version \([0-9]\{1,\}\.[0-9]\{1,\}\)\..*$/\1/')" != "2.8" ]

# Unpack Windows XP ISO.
RUN sha256sum en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso \
      | grep -q fd8c8d42c1581e8767217fe800bfc0d5649c0ad20d754c927d6c763e446d1927 \
    && 7z x -o'install' en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso \
    && rm en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso

# Install VirtIO drivers.
RUN wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.164-2/virtio-win-0.1.164.iso \
    && sha256sum virtio-win-0.1.164.iso \
      | grep -q 594678f509ba6827c7b75d076ecfb64d45c6ad95e9fccba7258e6eee9a6a3560 \
    && 7z x -o'virtio-win' virtio-win-0.1.164.iso \
    && mkdir -p 'install/$oem$/$1/drivers' \
    && cp -v virtio-win/viostor/xp/x86/* 'install/$oem$/$1/drivers' \
    && ([ "$QEMU_VGA" = "qxl" ] && cp -v virtio-win/qxl/xp/x86/* 'install/$oem$/$1/drivers' || true) \
    && cp -v virtio-win/NetKVM/xp/x86/* 'install/$oem$/$1/drivers' \
    && rm -rf virtio-win virtio-win-0.1.164.iso

# Install vmware display driver.
RUN if [ "$QEMU_VGA" = "vmware" ]; then \
      wget https://jurik-phys.net/files/kvm/vmwarevga32-kvm.iso \
      && sha256sum vmwarevga32-kvm.iso \
        | grep -q 38dd8852ec11261949103f459fe0c4d78435cebcd60d415aa7cc64230b78f9ce \
      && 7z x -o'vmwarevga32-kvm' vmwarevga32-kvm.iso \
      && mkdir -p 'install/$oem$/$1/drivers' \
      && cp -v vmwarevga32-kvm/vmx_* 'install/$oem$/$1/drivers' \
      && rm -rf vmwarevga32-kvm vmwarevga32-kvm.iso; \
    fi

# Install winnt.sif file.
RUN cp -v winnt.sif install/I386/WINNT.SIF \
    && sed -i "s/{productKey}/$PRODUCT_KEY/g" install/I386/WINNT.SIF \
    && sed -i "s/{screenWidth}/$SCREEN_WIDTH/g" install/I386/WINNT.SIF \
    && sed -i "s/{screenHeight}/$SCREEN_HEIGHT/g" install/I386/WINNT.SIF \
    && sed -i "s/{colorDepth}/$COLOR_DEPTH/g" install/I386/WINNT.SIF \
    && sed -i "s/{refreshRate}/$REFRESH_RATE/g" install/I386/WINNT.SIF \
    && rm winnt.sif

# Configure viostor for text mode installation.
RUN cp -v 'install/$oem$/$1/drivers/viostor.sys' 'install/I386' \
    && sed -i '$ d' install/I386/TXTSETUP.SIF \
    && cat txtsetup.sif >> install/I386/TXTSETUP.SIF \
    && rm txtsetup.sif

# Install Java RE setup.
RUN sha256sum jre-7u80-windows-i586.exe \
      | grep -q a87adf22064e2f7fa6ef64b2513533bf02aa0bf5265670e95b301a79d7ca89d9 \
    && mkdir -p 'install/$oem$/$1/selenium' \
    && cp -v jre-7u80-windows-i586.exe 'install/$oem$/$1/selenium' \
    && rm jre-7u80-windows-i586.exe

# Install Selenium Server.
RUN wget https://selenium-release.storage.googleapis.com/2.46/selenium-server-standalone-2.46.0.jar \
    && sha256sum selenium-server-standalone-2.46.0.jar \
      | grep -q deb997cfbbc29680b20e7af6960b5c49ecd5aa3e17fba0d3288cfb9c62a9b9e6 \
    && mkdir -p 'install/$oem$/$1/selenium' \
    && cp -v selenium-server-standalone-2.46.0.jar 'install/$oem$/$1/selenium' \
    && rm selenium-server-standalone-2.46.0.jar

# Install Selenium IE Driver.
RUN wget https://selenium-release.storage.googleapis.com/2.46/IEDriverServer_Win32_2.46.0.zip \
    && sha256sum IEDriverServer_Win32_2.46.0.zip \
      | grep -q 70d4e5887e527352aa40bf682338bccf005c1b972c58f3e2a605eea1a2bb986f \
    && mkdir -p 'install/$oem$/$1/selenium' \
    && 7z x -o'install/$oem$/$1/selenium' IEDriverServer_Win32_2.46.0.zip \
    && rm IEDriverServer_Win32_2.46.0.zip

# Install Internet Explorer 7 setup.
RUN if [ "$IE_VERSION" = 7 ]; then \
      wget https://download.microsoft.com/download/3/8/8/38889DC1-848C-4BF2-8335-86C573AD86D9/IE7-WindowsXP-x86-enu.exe \
      && sha256sum IE7-WindowsXP-x86-enu.exe \
        | grep -q bf5c325bbe3f4174869b2a8ff75f92833e7f7debe64777ed0faf293c7725cbef \
      && mkdir -p 'install/$oem$/$1/selenium' \
      && cp -v IE7-WindowsXP-x86-enu.exe 'install/$oem$/$1/selenium' \
      && rm IE7-WindowsXP-x86-enu.exe; \
    fi

# Install Internet Explorer 8 setup.
RUN if [ "$IE_VERSION" = 8 ]; then \
      wget https://download.microsoft.com/download/3/8/C/38CE0ABB-01FD-4C0A-A569-BC5E82C34A17/IE8-WindowsXP-KB2936068-x86-ENU.exe \
      && sha256sum IE8-WindowsXP-KB2936068-x86-ENU.exe \
        | grep -q 8bda23c78cdcd9d01c364a01c6d639dfb2d11550a5521b8a81c808c1a2b1824e \
      && mkdir -p 'install/$oem$/$1/selenium' \
      && cp -v IE8-WindowsXP-KB2936068-x86-ENU.exe 'install/$oem$/$1/selenium' \
      && rm IE8-WindowsXP-KB2936068-x86-ENU.exe; \
    fi

# Install bat scripts.
RUN mkdir -p 'install/$oem$/$1/selenium' \
    && cat once.bat | sed "s/{ieVersion}/$IE_VERSION/g" > 'install/$oem$/$1/selenium/once.bat' \
    && cp -v start.bat 'install/$oem$/$1/selenium' \
    && rm once.bat start.bat

# Build installation ISO.
RUN genisoimage \
      -no-emul-boot -boot-load-seg 1984 -boot-load-size 4 \
      -iso-level 2 -J -l -D -N -joliet-long -relaxed-filenames \
      -b '[BOOT]/Boot-NoEmul.img' -V 'GRTMPVOL_EN' -o install.iso install \
    && rm -rf install

# Create QEMU system disk.
RUN qemu-img create -f qcow2 system.qcow2 5G

# Install windows in unattended mode.
# Retry 5 times, it is typical that qemu could randomly crash on last steps
# of installation when it is running inside docker, in most cases it doesn't
# impact functionality and windows installation can successfully continue from
# the last crash.
RUN qemu-system-x86_64 \
      -vnc :$(echo $VNC_PORT - 5900 | bc) \
      -m $QEMU_RAM \
      -drive media=disk,file=system.qcow2,format=qcow2,if=virtio \
      -drive media=cdrom,file=install.iso \
      -boot once=d \
      -rtc base=utc \
      -usb \
      -device usb-tablet \
      -vga $QEMU_VGA \
      -device virtio-net,netdev=vmnic \
      -netdev user,id=vmnic

# Remove not needed anymore installation media.
RUN rm -rf install install.iso

# Remove not needed anymore tools.
RUN apt-get remove -y wget genisoimage p7zip-full

# Set main container script.
ENTRYPOINT ["/opt/qemu/entrypoint.sh"]
