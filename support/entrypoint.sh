#!/bin/bash

# detect vnc screen number
VNC_SCREEN=$(echo ${VNC_PORT} - 5900 | bc)

# detected selenium server role and related properties
if [ -n "$HUB_HOST" ]; then
  SE_OPTS="-role node -hub $HUB_HOST/grid/register"
else
  SE_OPTS="-role hub"
fi

# append node public url that is reachable by hub
if [ -n "$REMOTE_HOST" ]; then
  SE_OPTS="${SE_OPTS} -remoteHost $REMOTE_HOST"
fi

# create directory that will be shared with guest
mkdir -p /opt/qemu/shared

# copy start-node template to guest shared directory
cp /opt/qemu/start-node.bat /opt/qemu/shared/start-node.bat

# inject selenium properties into start-node
sed -i 's!{nodePort}!'"$NODE_PORT"'!g' /opt/qemu/shared/start-node.bat
sed -i 's!{seOpts}!'"$SE_OPTS"'!g' /opt/qemu/shared/start-node.bat
sed -i 's!{nodeMaxInstances}!'"$NODE_MAX_INSTANCES"'!g' /opt/qemu/shared/start-node.bat

# generate mac address if not already available or read previously generated
# 52:54:00 is well-known vendor prefix for QEMU virtual adapters
if [ ! -f macaddr.txt ]; then
  printf '52:54:00:%02X:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) > macaddr.conf
fi
MAC_ADDR=$(cat macaddr.conf)

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
  -nic user,model=$QEMU_NET,smb=/opt/qemu/shared,mac=${MAC_ADDR},hostfwd=tcp::${NODE_PORT}-:${NODE_PORT}
