#!/bin/bash

# detect vnc screen number
VNC_SCREEN=$(echo ${VNC_PORT} - 5900 | bc)

# detected selenium server role and related properties
if [ -n "$SELENIUM_HUB" ]; then
  SELENIUM_EXTRA_ARGS="-role node -hub $SELENIUM_HUB"
else
  SELENIUM_EXTRA_ARGS="-role hub"
fi

# create directory that will be shared with guest
mkdir -p /opt/qemu/shared

# copy start-node template to guest shared directory
cp /opt/qemu/start-node.bat /opt/qemu/shared/start-node.bat

# inject selenium properties into start-node
sed -i "s/{seleniumPort}/$SELENIUM_PORT/g" /opt/qemu/shared/start-node.bat
sed -i "s/{seleniumExtraArgs}/$SELENIUM_EXTRA_ARGS/g" /opt/qemu/shared/start-node.bat
sed -i "s/{seleniumInstances}/$SELENIUM_INSTANCES/g" /opt/qemu/shared/start-node.bat

# run actual qemu
# NOTE: thread=single makes wxp64 stable otherwise BSOD STOP 0x000000D1 or 0x0000001E
qemu-system-x86_64 \
  -accel kvm \
  -accel tcg,thread=single \
  -machine pc \
  -m $QEMU_RAM \
  -vnc :$VNC_SCREEN \
  -drive media=disk,file=/opt/qemu/system.qcow2,format=qcow2,if=$QEMU_DISK,cache=none,aio=native \
  -rtc base=utc \
  -usb \
  -device usb-tablet \
  -vga $QEMU_VGA \
  -nic user,model=$QEMU_NET,smb=/opt/qemu/shared,hostfwd=tcp::${SELENIUM_PORT}-:${SELENIUM_PORT}
