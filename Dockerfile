FROM debian:stretch

LABEL maintainer="art.sormy@gmail.com"

ENV SELENIUM_PORT=5555
ENV SELENIUM_HUB=
ENV VNC_PORT=5900
ENV QEMU_RAM=512

WORKDIR /opt/qemu

ADD build/system.qcow2 /opt/qemu/
ADD support/entrypoint.sh /opt/qemu/
ADD support/kvm-mknod.sh /opt/qemu/
ADD support/start-node.bat /opt/qemu/

RUN chmod +x /opt/qemu/*.sh

RUN apt-get update \
    && apt-get install -y qemu-kvm samba bc kmod \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/opt/qemu/entrypoint.sh"]
