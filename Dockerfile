FROM debian:buster

LABEL maintainer="art.sormy@gmail.com"

# Build parameters.
ARG PRODUCT_KEY
ARG WIN_ARCH
ARG IE_VERSION=6
ARG ORG_NAME=oldie
ARG QEMU_RAM=512
ARG QEMU_VGA
ARG QEMU_NET=virtio
ARG QEMU_DISK=virtio
ARG SCREEN_WIDTH=1024
ARG SCREEN_HEIGHT=768
ARG COLOR_DEPTH=32
ARG REFRESH_RATE=60

# Runtime parameters.
ENV SELENIUM_PORT=5555
ENV SELENIUM_HUB=
ENV REMOTE_HOST=
ENV SELENIUM_INSTANCES=1
ENV VNC_PORT=5900
ENV QEMU_RAM=${QEMU_RAM}
ENV QEMU_VGA=${QEMU_VGA}
ENV QEMU_NET=${QEMU_NET}
ENV QEMU_DISK=${QEMU_DISK}

# Verify build arguments.
RUN [ -n "$PRODUCT_KEY" ]
RUN [ "$WIN_ARCH" = 32 ] || [ "$WIN_ARCH" = 64 ]
RUN [ "$IE_VERSION" = 6 ] || [ "$IE_VERSION" = 7 ] || [ "$IE_VERSION" = 8 ]
# NOTE: Unfortunately, qxl is not available for 64bit windows xp or windows 2003
RUN [ "$WIN_ARCH" = 32 ] || [ "$QEMU_VGA" != "qxl" ]
RUN [ -n "$QEMU_VGA" ]

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

# Unpack Windows XP 32bit ISO.
RUN if [ "$WIN_ARCH" = 32 ]; then \
      sha256sum en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso \
        | grep -q fd8c8d42c1581e8767217fe800bfc0d5649c0ad20d754c927d6c763e446d1927 \
      && 7z x -aoa -o'install' en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso \
      && rm en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso; \
    fi

# Unpack Windows XP 64bit ISO.
RUN if [ "$WIN_ARCH" = 64 ]; then \
      sha256sum en_win_xp_pro_x64_with_sp2_vl_X13-41611.iso \
        | grep -q ace108a116ed33ddbfd6b7e2c5f21bcef9b3ba777ca9a8052730138341a3d67d \
      && 7z x -aoa -o'install' en_win_xp_pro_x64_with_sp2_vl_X13-41611.iso \
      && rm en_win_xp_pro_x64_with_sp2_vl_X13-41611.iso; \
    fi

# Install VirtIO drivers.
RUN if [ "$QEMU_DISK" = "virtio" ] || [ "$QEMU_NET" = "virtio" ] || [ "$QEMU_VGA" = "qxl" ]; then \
      wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.164-2/virtio-win-0.1.164.iso \
      && sha256sum virtio-win-0.1.164.iso \
        | grep -q 594678f509ba6827c7b75d076ecfb64d45c6ad95e9fccba7258e6eee9a6a3560 \
      && 7z x -aoa -o'virtio-win' virtio-win-0.1.164.iso \
      && mkdir -p 'install/$oem$/$1/drivers' \
      && DRIVER_PATH=`[ "$WIN_ARCH" = 32 ] && echo "xp/x86" || echo "2k3/amd64"` \
      && ([ "$QEMU_DISK" = "virtio" ] \
          && cp -v virtio-win/viostor/$DRIVER_PATH/* 'install/$oem$/$1/drivers' \
          || true) \
      && ([ "$QEMU_NET" = "virtio" ] \
          && cp -v virtio-win/NetKVM/$DRIVER_PATH/* 'install/$oem$/$1/drivers' \
          || true) \
      && ([ "$QEMU_VGA" = "qxl" ] && [ "$WIN_ARCH" = 32 ] \
          && cp -v virtio-win/qxl/$DRIVER_PATH/* 'install/$oem$/$1/drivers' \
          || true) \
      && rm -rf virtio-win virtio-win-0.1.164.iso; \
    fi

# Install VMWare display driver (32bit).
RUN if [ "$QEMU_VGA" = "vmware" ] && [ "$WIN_ARCH" = 32 ]; then \
      wget https://jurik-phys.net/files/kvm/vmwarevga32-kvm.iso \
      && sha256sum vmwarevga32-kvm.iso \
        | grep -q 38dd8852ec11261949103f459fe0c4d78435cebcd60d415aa7cc64230b78f9ce \
      && 7z x -aoa -o'vmwarevga-kvm' vmwarevga32-kvm.iso \
      && mkdir -p 'install/$oem$/$1/drivers' \
      && cp -v vmwarevga-kvm/vmx_* 'install/$oem$/$1/drivers' \
      && rm -rf vmwarevga-kvm vmwarevga32-kvm.iso; \
    fi

# Install VMWare display driver (64bit).
RUN if [ "$QEMU_VGA" = "vmware" ] && [ "$WIN_ARCH" = 64 ]; then \
      wget https://jurik-phys.net/files/kvm/vmwarevga64-kvm-2.iso \
      && sha256sum vmwarevga64-kvm-2.iso \
        | grep -q cc55850a0eb9ebbaae94bff6628b5e817f9837ca65a89cefd9a428264abacb6d \
      && 7z x -aoa -o'vmwarevga-kvm' vmwarevga64-kvm-2.iso \
      && mkdir -p 'install/$oem$/$1/drivers' \
      && cp -v vmwarevga-kvm/vmx_* 'install/$oem$/$1/drivers' \
      && rm -rf vmwarevga-kvm vmwarevga64-kvm-2.iso; \
    fi

# Install winnt.sif file.
RUN TARGET_DIR=`[ "$WIN_ARCH" = 32 ] && echo "I386" || echo "AMD64"` \
    && cp -v winnt.sif install/$TARGET_DIR/WINNT.SIF \
    && sed -i "s/{productKey}/$PRODUCT_KEY/g" install/$TARGET_DIR/WINNT.SIF \
    && sed -i "s/{orgName}/$ORG_NAME/g" install/$TARGET_DIR/WINNT.SIF \
    && sed -i "s/{screenWidth}/$SCREEN_WIDTH/g" install/$TARGET_DIR/WINNT.SIF \
    && sed -i "s/{screenHeight}/$SCREEN_HEIGHT/g" install/$TARGET_DIR/WINNT.SIF \
    && sed -i "s/{colorDepth}/$COLOR_DEPTH/g" install/$TARGET_DIR/WINNT.SIF \
    && sed -i "s/{refreshRate}/$REFRESH_RATE/g" install/$TARGET_DIR/WINNT.SIF \
    && rm winnt.sif

# Configure viostor for text mode installation.
RUN if [ "$QEMU_DISK" = "virtio" ]; then \
      TARGET_DIR=`[ "$WIN_ARCH" = 32 ] && echo "I386" || echo "AMD64"` \
      && cp -v 'install/$oem$/$1/drivers/viostor.sys' install/$TARGET_DIR \
      && sed -i '$ d' install/$TARGET_DIR/TXTSETUP.SIF \
      && cat txtsetup.sif >> install/$TARGET_DIR/TXTSETUP.SIF \
      && rm txtsetup.sif; \
    fi

# Install Java RE setup.
RUN sha256sum jre-7u80-windows-i586.exe \
      | grep -q a87adf22064e2f7fa6ef64b2513533bf02aa0bf5265670e95b301a79d7ca89d9 \
    && mkdir -p 'install/$oem$/$1/provision' \
    && cp -v jre-7u80-windows-i586.exe 'install/$oem$/$1/provision' \
    && rm jre-7u80-windows-i586.exe

# Install Selenium Server.
RUN wget https://selenium-release.storage.googleapis.com/2.46/selenium-server-standalone-2.46.0.jar \
    && sha256sum selenium-server-standalone-2.46.0.jar \
      | grep -q deb997cfbbc29680b20e7af6960b5c49ecd5aa3e17fba0d3288cfb9c62a9b9e6 \
    && mkdir -p 'install/$oem$/$1/provision' \
    && cp -v selenium-server-standalone-2.46.0.jar 'install/$oem$/$1/provision' \
    && rm selenium-server-standalone-2.46.0.jar

# Install Selenium IE Driver.
RUN wget https://selenium-release.storage.googleapis.com/2.46/IEDriverServer_Win32_2.46.0.zip \
    && sha256sum IEDriverServer_Win32_2.46.0.zip \
      | grep -q 70d4e5887e527352aa40bf682338bccf005c1b972c58f3e2a605eea1a2bb986f \
    && mkdir -p 'install/$oem$/$1/provision' \
    && 7z x -aoa -o'install/$oem$/$1/provision' IEDriverServer_Win32_2.46.0.zip \
    && rm IEDriverServer_Win32_2.46.0.zip

# Install Internet Explorer 7 32bit setup.
RUN if [ "$IE_VERSION" = 7 ] && [ "$WIN_ARCH" = 32 ]; then \
      wget https://download.microsoft.com/download/3/8/8/38889DC1-848C-4BF2-8335-86C573AD86D9/IE7-WindowsXP-x86-enu.exe \
      && sha256sum IE7-WindowsXP-x86-enu.exe \
        | grep -q bf5c325bbe3f4174869b2a8ff75f92833e7f7debe64777ed0faf293c7725cbef \
      && mkdir -p 'install/$oem$/$1/provision' \
      && cp -v IE7-WindowsXP-x86-enu.exe 'install/$oem$/$1/provision' \
      && rm IE7-WindowsXP-x86-enu.exe; \
    fi

# Install Internet Explorer 7 64bit setup.
RUN if [ "$IE_VERSION" = 7 ] && [ "$WIN_ARCH" = 64 ]; then \
      wget https://download.microsoft.com/download/1/1/4/114d5b07-4dbc-42f3-96fa-2097e207d0af/IE7-WindowsServer2003-x64-enu.exe \
      && sha256sum IE7-WindowsServer2003-x64-enu.exe \
        | grep -q 1050f2620a2646ca007a473953ee2e6cba6f561ce88df34a681e7680a4a6d032 \
      && mkdir -p 'install/$oem$/$1/provision' \
      && cp -v IE7-WindowsServer2003-x64-enu.exe 'install/$oem$/$1/provision' \
      && rm IE7-WindowsServer2003-x64-enu.exe; \
    fi

# Install Internet Explorer 8 32bit setup.
RUN if [ "$IE_VERSION" = 8 ] && [ "$WIN_ARCH" = 32 ]; then \
      wget https://download.microsoft.com/download/3/8/C/38CE0ABB-01FD-4C0A-A569-BC5E82C34A17/IE8-WindowsXP-KB2936068-x86-ENU.exe \
      && sha256sum IE8-WindowsXP-KB2936068-x86-ENU.exe \
        | grep -q 8bda23c78cdcd9d01c364a01c6d639dfb2d11550a5521b8a81c808c1a2b1824e \
      && mkdir -p 'install/$oem$/$1/provision' \
      && cp -v IE8-WindowsXP-KB2936068-x86-ENU.exe 'install/$oem$/$1/provision' \
      && rm IE8-WindowsXP-KB2936068-x86-ENU.exe; \
    fi

# Install Internet Explorer 8 64bit setup.
RUN if [ "$IE_VERSION" = 8 ] && [ "$WIN_ARCH" = 64 ]; then \
      wget https://download.microsoft.com/download/7/5/4/754D6601-662D-4E39-9788-6F90D8E5C097/IE8-WindowsServer2003-x64-ENU.exe \
      && sha256sum IE8-WindowsServer2003-x64-ENU.exe \
        | grep -q bcff753e92ceabf31cfefaa6def146335c7cb27a50b95cd4f4658a0c3326f499 \
      && mkdir -p 'install/$oem$/$1/provision' \
      && cp -v IE8-WindowsServer2003-x64-ENU.exe 'install/$oem$/$1/provision' \
      && rm IE8-WindowsServer2003-x64-ENU.exe; \
    fi

# Install bat scripts.
RUN mkdir -p 'install/$oem$/$1/provision' \
    && cp -v once.bat start.bat 'install/$oem$/$1/provision' \
    && rm once.bat start.bat

# Build installation ISO.
RUN genisoimage \
      -no-emul-boot -boot-load-seg 1984 -boot-load-size 4 \
      -iso-level 2 -J -l -D -N -joliet-long -relaxed-filenames \
      -b '[BOOT]/Boot-NoEmul.img' -o install.iso install \
    && rm -rf install

# Create QEMU system disk.
RUN qemu-img create -f qcow2 system.qcow2 5G

# Install windows in unattended mode.
# NOTE: thread=single makes wxp64 stable otherwise BSOD STOP 0x000000D1 or 0x0000001E
RUN qemu-system-x86_64 \
      -accel kvm \
      -accel tcg,thread=single \
      -machine pc \
      -m $QEMU_RAM \
      -vnc :$(echo $VNC_PORT - 5900 | bc) \
      -drive media=disk,file=system.qcow2,format=qcow2,if=$QEMU_DISK,cache=none,aio=native,l2-cache-size=4M \
      -drive media=cdrom,file=install.iso \
      -boot once=d \
      -rtc base=utc \
      -usb \
      -device usb-tablet \
      -vga $QEMU_VGA \
      -nic user,model=$QEMU_NET,restrict=on

# Remove not needed anymore installation media.
RUN rm -rf install *.iso

# Remove not needed anymore tools.
RUN apt-get remove -y wget genisoimage p7zip-full

# Set main container script.
ENTRYPOINT ["/opt/qemu/entrypoint.sh"]
