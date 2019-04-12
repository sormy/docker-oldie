#!/bin/bash

# try to initialize kvm for qemu hardware acceleration (if available)
# from https://github.com/kevinwallace/qemu-docker/blob/master/kvm-mknod.sh
/opt/qemu/kvm-mknod.sh

# detect vnc screen number
VNC_SCREEN=$(echo ${VNC_PORT} - 5900 | bc)

# detected selenium server role and related properties
if [ -n "$SELENIUM_HUB" ]; then
  SELENIUM_EXTRA_ARGS="-role node -hub $SELENIUM_HUB"
else
  SELENIUM_EXTRA_ARGS=""
fi

# create directory that will be shared with guest
mkdir -p /opt/qemu/shared

# copy start-node template to guest shared directory
cp /opt/qemu/start-node.bat /opt/qemu/shared/start-node.bat

# inject selenium properties into start-node
sed -i "s/{seleniumPort}/$SELENIUM_PORT/g" /opt/qemu/shared/start-node.bat
sed -i "s/{seleniumExtraArgs}/$SELENIUM_EXTRA_ARGS/g" /opt/qemu/shared/start-node.bat

# run actual qemu
qemu-system-x86_64 \
  -m ${QEMU_RAM} \
  -drive media=disk,file=/opt/qemu/system.qcow2,format=qcow2,if=virtio \
  -vnc :${VNC_SCREEN} \
  -rtc base=utc \
  -usb \
  -device usb-tablet \
  -vga std \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,smb=/opt/qemu/shared,hostfwd=tcp::${SELENIUM_PORT}-:${SELENIUM_PORT}
