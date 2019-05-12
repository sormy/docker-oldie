# Docker with Internet Explorer 6/7/8

Docker image with QEMU, VNC access, Windows XP, IE 6/7/8 and Selenium Server.

Ideal to run integration tests on ancient IE 6/7/8 in cloud or locally.

The build script is designed to use official windows xp msdn iso images. It will
unpack image, inject drivers and configuration and will install it as qemu guest.

The build script will also install Java, Selenium Server, Internet Explorer 7/8
(if requested) and will tune registry to make instance easier to use with Selenium.

## Prerequisites

### Windows XP ISO

Tested and supported Windows XP ISO images:

* Windows XP Pro SP3 **32bit** English Corporate
  * File: en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso
  * SHA1: 66ac289ae27724c5ae17139227cbe78c01eefe40
  * SHA256: fd8c8d42c1581e8767217fe800bfc0d5649c0ad20d754c927d6c763e446d1927
* Windows XP Pro SP2 **64bit** English Corporate
  * File: en_win_xp_pro_x64_with_sp2_vl_X13-41611.iso
  * SHA1: cd9479e1dbad7f26b8bdcf97e4aa71cbb8de932b
  * SHA256: ace108a116ed33ddbfd6b7e2c5f21bcef9b3ba777ca9a8052730138341a3d67d

After downloading put image file into `files` directory.

Use `WIN_ARCH` build argument to choose what image to use.

You could always confirm hashes for official MSDN distributions here:

* https://msdn.lol-inter.net/
* http://www.heidoc.net/php/myvsdump.php

### Java RE

Java RE 7.x is needed to run Selenium Server.

Java RE 7.x that is compatible with Windows XP is not available for downloading
without registering Oracle account these days. You could download file manualy.

* File: jre-7u80-windows-i586.exe
* SHA256: a87adf22064e2f7fa6ef64b2513533bf02aa0bf5265670e95b301a79d7ca89d9

After downloading put the file into `files` directory.

## Legal Rights

Internet Explorer 6/7/8 were released for Windows XP and are not available for
Windows Vista/7/8/8.1/10.

The only legal way to run Windows XP these days is to use right to downgrade:
https://download.microsoft.com/download/6/8/9/68964284-864d-4a6d-aed9-f2c1f8f23e14/downgrade_rights.pdf

> For Windows 10 licenses acquired though Commercial Licensing, you may downgrade
> to any prior version of the licensed Windows edition.

> If you have legally obtained physical media (CD/DVD) of earlier Microsoft products
> that your organization is currently licensed to use through downgrade rights,
> you may use these prior software versions at your discretion.

Windows XP activation services could be down these days and the only way to get it
working is to use Windows XP Corporate Edition that doesn't require activation.

You will need to use previosly legally obtained media and install with previosly
legally obtained product key.

Only Windows 10 retail version is eligible for right to downgrade (OEM is not).

You could confirm if Windows 10 Product Key is Retail or not using `ShowKeyPlus`
utility: https://github.com/Superfly-Inc/ShowKeyPlus/releases

## Building inside container

Docker doesn't have an option to build image with privileged access so
port forwarding and hardware acceleration for emulation won't be available
during the build.

That mean that image build won't as fast as kvm and there will be no way to see
installation progress using VNC viewer.

The process is running around 45-60 mins on Macbook Pro 2017 Core i7 (no kvm).

Usage:

```
docker build \
  --build-arg PRODUCT_KEY={PRODUCT_KEY} \
  --build-arg IE_VERSION={IE_VERSION} \
  --build-arg WIN_ARCH={WIN_ARCH} \
  --build-arg QEMU_VGA={QEMU_VGA} \
  -t {IMAGE_NAME} .
```

Example (IE7 running on Windows XP 64bit):

```bash
docker build \
  --build-arg PRODUCT_KEY=AAAAA-BBBBB-CCCCC-DDDDD-EEEEE \
  --build-arg IE_VERSION=7 \
  --build-arg WIN_ARCH=64 \
  --build-arg QEMU_VGA=std \
  --build-arg ORG_NAME=MyOrg \
  -t wxp64-ie7 .
```

Example (IE7 running on Windows XP 32bit):

```bash
docker build \
  --build-arg PRODUCT_KEY=AAAAA-BBBBB-CCCCC-DDDDD-EEEEE \
  --build-arg IE_VERSION=7 \
  --build-arg WIN_ARCH=32 \
  --build-arg QEMU_VGA=qxl \
  --build-arg ORG_NAME=MyOrg \
  -t wxp32-ie7 .
```

Build Arguments:

- `PRODUCT_KEY` - Windows XP Pro Corporate Product Key (**required**)
- `WIN_ARCH` - Windows XP Architecture (**required**): `32` bit or `64` bit
- `IE_VERSION` - Internet Explorer version: `6` (default), `7` or `8`
- `ORG_NAME` - Organization name (`oldie` by default)
- `QEMU_RAM` - amount of RAM in MB shared with QEMU instance (`512` by default)
- `QEMU_VGA` - QEMU video device model (**required**)
  - See more information in QEMU documentation for `-vga` parameter
  - Available values: `cirrus`, `std`, `wmware`, `qxl`
  - Windows XP 32bit recommendation: `qxl`
  - Windows XP 64bit recommendation: `std`
- `QEMU_NET` - QEMU network device model (`virtio` by default)
- `QEMU_DISK` - QEMU disk device model (`virtio` by default)
- `SCREEN_WIDTH` - screen width (`1024` by default)
- `SCREEN_HEIGHT` - screen height (`768` by default)
- `SCREEN_DEPTH` - color depth (`32` bits by default)
- `REFRESH_RATE` - refresh rate (`60` Hz by default)

## Building locally on the host

The building process is much faster (if kvm is available) and easier to debug
if system image build is performed on host and then system image is copied into
container.

Local building script is not cleaning up after for debugging purposes.

The process is running around 45-60 mins on Macbook Pro 2017 Core i7 (no kvm).

These dependencies need to be installed to build on macOS host:

```
# run the build script
brew install qemu coreutils gnu-sed wget cdrtools p7zip
# see the installation progress using vnc viewer (will be automatically launched)
brew install tiger-vnc
```

These dependencies need to be installed to build on Debian-like distro:

```
apt-get install -y qemu-kvm bc wget genisoimage p7zip-full
```

Local build process has these steps:

- generate build system image script
- build system image
- build docker image

Usage:

```
# create build and docker scripts
./local-configure

# build system image, pass build arguments using shell environment varibles
PRODUCT_KEY={PRODUCT_KEY} IE_VERSION={IE_VERSION} WIN_ARCH={WIN_ARCH} QEMU_VGA={QEMU_VGA} ./local-build

# build docker image, pass build arguments using docker build arguments
cp -v Dockerfile.local build/Dockerfile
cd build \
  && docker build --build-arg QEMU_VGA={QEMU_VGA} -t {IMAGE_NAME} . \
  && cd -
```

Script `local-configure` will parse `Dockerfile` and convert to shell script on
the fly that will be executed locally to build system image.

All docker build arguments could be passed as shell environment variables to
`local-build`.

QEMU screen will be available on VNC 5900 port by default during local build.

These build arguments must be also passed to `docker build` command:

* `QEMU_VGA` - **required**
* `QEMU_NET` - if modified from default value
* `QEMU_DISK` - if modified from default value

## Running

Run container:

```bash
docker run -d -p 5900:5900 -p 5555:5555 --privileged {IMAGE_NAME}
```

Example (running node that joins the hub):

```bash
# run one selenium node reachable by http://selenium-node-1.domain.com:5555
docker run \
  -d \
  -p 5900:5900 \
  -p 5555:5555 \
  -e HUB_HOST=http://selenium-hub.domain.com:4444 \
  -e REMOTE_HOST=http://$(hostname):5555 \
  --privileged \
  wxp64-ie7

# run second selenium node reachable by http://selenium-node-2.domain.com:5556
docker run \
  -d \
  -p 5901:5900 \
  -p 5556:5555 \
  -e HUB_HOST=http://selenium-hub.domain.com:4444 \
  -e REMOTE_HOST=http://$(hostname):5556 \
  --privileged \
  wxp64-ie7
```

Options:

- `--privileged` - required to make network access working inside QEMU guest
- `-v /dev/kvm:/dev/kvm` - enable nested kvm virtualization if available
- `-p {hostPort}:{guestPort}` - forward port to container
  - `5900` is used for VNC by default
  - `5555` is used by Selenium node by default
- `-e {varName}={varValue}` - pass environment variable to container
  - `NODE_PORT` - run selenium node on this port (`5555` by default).
    It is not recommended to change this port, you could change host port on docker
    level and provide right `REMOTE_HOST` value including host port.
  - `HUB_HOST` - hub public url including port like `http://selenium-hub.domain.com:4444`
  - `REMOTE_HOST` - node public url including port like `http://selenium-node-1.domain.com:5555`
  - `NODE_MAX_INSTANCES` - number of allowed browser instances (`1` by default)
  - `VNC_PORT` - run VNC screen on this port (`5900` by default, must be not lower than `5900`).
    It is not recommended to change this port, you could change host port on docker level.
  - `QEMU_RAM` - amount of RAM in MB shared with QEMU instance (`512` by default).
    Change this value depending on number of instances you would like to run in container.

You could run multiple containers using different VNC and Selenium ports.

If you don't need to see what is happening on instance using VNC viewer then
just don't forward VNC port.

It is recommended to use Selenium Server hub v2.53.1. The recommended docker image
for hub is <https://github.com/sormy/docker-selenium>.

## Amazon Linux and ECR

This image could be also built using Amazon Linux as base for deployment to ECR.

Run the command below to generate `Dockerfile.amazonlinux`:

```
./amazonlinux-configure
```

Building:

```
docker build \
  --build-arg PRODUCT_KEY={PRODUCT_KEY} \
  --build-arg IE_VERSION={IE_VERSION} \
  --build-arg WIN_ARCH={WIN_ARCH} \
  --build-arg QEMU_VGA={QEMU_VGA} \
  -f Dockerfile.amazonlinux \
  -t {IMAGE_NAME} .
```

## FAQ

* Q: Why does this script check SHA256 for all files?
* A: For security purposes script doesn't trust files downloaded from internet.

* Q: Why VGA driver is different for Windows XP 32 bit and 64 bit windows?
* A: Windows XP 64 bit has different set of integrated drivers and some virtio
  drivers are just not available for Windows XP 64 bit. `qxl` is available only
  on 32 bit. `cirrus` is slow but is available on both. `std` is available only
  on 64 bit. `wmware` is buggy based on publicly available information.

## Contribution

Feel free to submit a PR for new features or/and bug fixes (if any).

These are features I think could be valuable for this project:

- Disable PXE boot delay
- Mark ethernet and storage devices as not external
- Disable screensaver
- Remove desktop walpaper
- Share clipboard over VNC (qemu spice only?)
- Set screen resolution and etc in runtime?
- Automatically install drivers for video adapater if QEMU_VGA has changed.
- Do one login after setup to make next login much faster
- Web-based viewer (noVNC, for example)
- Add VNC authentication (password, for example)
- Show network icon for network adapter?
- Option to install custom trusted SSL certificates in runtime
- Allow to use other windows xp images (need to test)?
- Speedup windows xp (disable unneeded features and services)
- Dubug installation process in docker (record VNC video to file?)
- IE 5.5 (using Windows 2000 Pro)
- Add Docker HEALTHCHECK
- Test different accel value: kvm, xen, hax
- QEMU balloon driver and service
- QEMU guest agent
- AWS ECR REMOTE_HOST auto discovery

## License

MIT
