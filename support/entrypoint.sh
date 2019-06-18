#!/bin/bash

set -ex

# if svm (intel) or vmx (amd) is available then try to create kvm device (if not exists)
if grep -q 'svm\|vmx' /proc/cpuinfo && [ ! -c /dev/kvm ]; then
  mknod /dev/kvm c 10 "$(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')" || true
fi

# TODO: doesn't work on awsvpc networking
# discover SE_REMOTE_HOST if AWS is detected
if [ -z "$SE_REMOTE_HOST" ] && [ -n "$AWS_EXECUTION_ENV" ]; then
  # delay host port detection to make sure that host port assignment is completed
  sleep 2s

  # use ecs agent introspection to discover host port
  # see: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-introspection.html
  ECS_HOST_PORT=$(
    curl -s "http://172.17.0.1:51678/v1/tasks?dockerid=$HOSTNAME" \
      | jq ".Containers[0].Ports[] | select(.ContainerPort == $SE_PORT) | .HostPort // empty"
  )
  [ -n "$ECS_HOST_PORT" ]

  # use ec2 instance metadata to discover local hostname
  # see: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
  ECS_LOCAL_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)
  [ -n "$ECS_LOCAL_HOSTNAME" ]

  SE_REMOTE_HOST="http://$ECS_LOCAL_HOSTNAME:$ECS_HOST_PORT"
fi

# set explicit role and port
SE_OPTS="$SE_OPTS -role node -port $SE_PORT"

# join hub if available, otherwise don't register to hub
if [ -n "$SE_HUB" ]; then
  SE_OPTS="$SE_OPTS -hub $SE_HUB/grid/register"
else
  SE_OPTS="$SE_OPTS"
  # TODO: add "-register false" for Selenium Server 3.x
fi

# set remote host if available
if [ -n "$SE_REMOTE_HOST" ]; then
  SE_OPTS="$SE_OPTS -remoteHost $SE_REMOTE_HOST"
fi

# build browser capabilities config
SE_BROWSER="browserName=$BROWSER_NAME,version=$BROWSER_VERSION,platformName=$BROWSER_PLATFORM,maxInstances=$BROWSER_MAX_INSTANCES"

# create directory that will be shared with guest
mkdir -p /opt/qemu/shared

# generate start-node using selenium properties and start-node template
cat /opt/qemu/start-node.bat \
  | sed \
      -e 's!{seOpts}!'"$SE_OPTS"'!g' \
      -e 's!{seLogLevel}!'"$SE_LOG_LEVEL"'!g' \
      -e 's!{seBrowser}!'"$SE_BROWSER"'!g' \
  > /opt/qemu/shared/start-node.bat

# generate mac address if not already available or read previously generated
# 52:54:00:XX:XX:XX is well-known vendor prefix for QEMU virtual adapters
if [ ! -f macaddr.txt ]; then
  printf '52:54:00:%02X:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) > macaddr.conf
fi
MAC_ADDR=$(cat macaddr.conf)

# network configuration: qemu -> tap0 -> br0 -> MASQUARADE -> world
BRIDGE_IF="br0"
TAP_IF="tap0"
BRIDGE_INET="192.168.234.1/30 brd 192.168.234.3"
BRIDGE_ADDR="192.168.234.1"
GUEST_ADDR="192.168.234.2"

# create tun device so we could create tap interface and connect it to the bridge
if [ ! -c /dev/net/tun ]; then
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
fi

# check network configuration
[ $(cat /proc/sys/net/ipv4/ip_forward) = 1 ]

# setup network bridge with NAT
ip link add name $BRIDGE_IF type bridge
ip link set $BRIDGE_IF up
ip address add $BRIDGE_INET dev $BRIDGE_IF
ip tuntap add $TAP_IF mode tap user $(whoami)
ip link set $TAP_IF up
ip link set $TAP_IF master $BRIDGE_IF
iptables -t nat -A POSTROUTING -s $GUEST_ADDR -j MASQUERADE

# run dhcp/dns server to configure guest's network interface
dnsmasq \
    --strict-order \
    --except-interface=lo \
    --interface=$BRIDGE_IF \
    --listen-address=$BRIDGE_ADDR \
    --bind-interfaces \
    --dhcp-range=$GUEST_ADDR,$GUEST_ADDR,24h \
    --conf-file="" \
    --dhcp-no-override

# minimal samba config to share settings with guest
cat << END > /etc/samba/smb.conf
[global]
workgroup = WORKGROUP
server role = standalone server
security = user
map to guest = Bad User
interfaces = $BRIDGE_ADDR
bind interfaces only = yes

[qemu]
path = /opt/qemu/shared
writeable = yes
browsable = yes
guest ok = yes
END

# run samba server
smbd

# reverse proxy node port
socat tcp-listen:$SE_PORT,fork,su=nobody tcp:$GUEST_ADDR:$SE_PORT &

# run actual qemu
# NOTE: thread=single makes wxp64 stable otherwise BSOD STOP 0x000000D1 or 0x0000001E
# NOTE: user-mode networking is very unstable in docker on EC2, so bridge is used
# NOTE: exec is needed to make sure that TERM signal will be forwarded to qemu process
exec qemu-system-x86_64 \
  -name $HOSTNAME \
  -accel kvm \
  -accel tcg,thread=single \
  -machine pc \
  -m $QEMU_RAM \
  $([ "$VNC_ENABLED" = 1 ] && echo "-vnc :$(($VNC_PORT - 5900))") \
  -drive media=disk,file=/opt/qemu/system.qcow2,format=qcow2,if=$QEMU_DISK,cache=none,aio=native \
  -boot order=c \
  -rtc base=utc \
  -usb \
  -device usb-tablet \
  -vga $QEMU_VGA \
  -nic tap,model=$QEMU_NET,ifname=$TAP_IF,mac=$MAC_ADDR,script=no,downscript=no
