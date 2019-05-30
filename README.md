# Docker with Internet Explorer 6/7/8

## About

This docker image is designed to run Internet Explorer 6/7/8 sandboxed in Docker
container for manual testing or automated testing using webdriver protocol
(using Selenium Server) locally or in cloud.

Supported Browsers:

- Internet Explorer 6 (32bit or 64bit on 64bit OS)
- Internet Explorer 7 (32bit or 64bit on 64bit OS)
- Internet Explorer 8 (32bit or 64bit on 64bit OS)

Supported OS:

- Windows XP 32bit English Corporate
- Windows XP 64bit English Corporate

Webdriver:

- Selenium Server 3.x
- OpenJDK 8 (32bit or 64bit)
- IE Driver 2.46

Virtualization:

- QEMU 4.x with KVM or TCG (software)

Debugging:

- VNC (integrated in QEMU)

Cloud:

- ECS auto discovery for `-remoteHost` Selenium Server option.

## Legal Rights

Internet Explorer 6/7/8 are not available for Windows Vista/7/8/8.1/10.
The latest OS where they were available is Window XP.

The only legal way to run Windows XP these days is to use right to downgrade:
https://download.microsoft.com/download/6/8/9/68964284-864d-4a6d-aed9-f2c1f8f23e14/downgrade_rights.pdf

> For Windows 10 licenses acquired though Commercial Licensing, you may downgrade
> to any prior version of the licensed Windows edition.

> If you have legally obtained physical media (CD/DVD) of earlier Microsoft products
> that your organization is currently licensed to use through downgrade rights,
> you may use these prior software versions at your discretion.

You will need to use previosly legally obtained media and previosly legally
obtained product key.

Only Windows 10 **Retail** version is eligible for right to downgrade (OEM is not).

You could confirm if Windows 10 Product Key is Retail or not using `ShowKeyPlus`
utility: https://github.com/Superfly-Inc/ShowKeyPlus/releases

## Tested Configurations

Tested Windows XP images:

* Windows XP Pro SP3 **32bit** English Corporate
  * File: en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso
  * SHA1: 66ac289ae27724c5ae17139227cbe78c01eefe40
  * SHA256: fd8c8d42c1581e8767217fe800bfc0d5649c0ad20d754c927d6c763e446d1927
* Windows XP Pro SP2 **64bit** English Corporate
  * File: en_win_xp_pro_x64_with_sp2_vl_X13-41611.iso
  * SHA1: cd9479e1dbad7f26b8bdcf97e4aa71cbb8de932b
  * SHA256: ace108a116ed33ddbfd6b7e2c5f21bcef9b3ba777ca9a8052730138341a3d67d

OEM and Retail editions won't work because they require activation.

Other languages won't work because `start-node.bat` script is relying on English
OS language.

Images without service packs should work but it was not tested. `WIN_ISO_FILE`
and `WIN_ISO_SHA256` must be explicily provided using Docker build arguments
in that case.

You could always confirm hashes for official MSDN distributions here:

* https://msdn.lol-inter.net/
* http://www.heidoc.net/php/myvsdump.php

## Building

### Docker Only

Docker doesn't have an option to build image with privileged access and port
forwarding so VNC and hardware acceleration for emulation won't be available
during the build.

The process should take around 45-60 mins.

Put Windows XP installation ISO file into `files` directory.

Usage:

```sh
docker build \
  --build-arg PRODUCT_KEY={PRODUCT_KEY} \
  --build-arg IE_VERSION={IE_VERSION} \
  -f Dockerfile.{PLATFORM} \
  -t {IMAGE_NAME} .
```

Example (IE7 running on Windows XP 32bit):

```sh
docker build \
  --build-arg PRODUCT_KEY=AAAAA-BBBBB-CCCCC-DDDDD-EEEEE \
  --build-arg IE_VERSION=7 \
  -t wxp32-ie7 .
```

Example (IE7 running on Windows XP 64bit):

```sh
docker build \
  --build-arg PRODUCT_KEY=AAAAA-BBBBB-CCCCC-DDDDD-EEEEE \
  --build-arg IE_VERSION=7 \
  -f Dockerfile.wxp64 \
  -t wxp64-ie7 .
```

Build files have a lot of build arguments but almost all of them have reasonable
defaults that are not recommended to change unless you know what you are doing.

Use these build arguments to install OpenJDK 64bit on 64bit OS:

```sh
JAVA_MSI_URL=https://github.com/ojdkbuild/ojdkbuild/releases/download/1.8.0.212-1/java-1.8.0-openjdk-1.8.0.212-1.b04.ojdkbuild.windows.x86_64.msi
JAVA_MSI_SHA256=eb49790e82220fc4a4884db5adc24d2dcd21e71d3f955acb8c29139355da3ac4
JAVA_ARCH=x86_64
```

Use these build arguments to use Internet Explorer 64bit with Selenium on 64bit OS:

```sh
IE_DRIVER_URL=https://selenium-release.storage.googleapis.com/2.46/IEDriverServer_x64_2.46.0.zip
IE_DRIVER_SHA256=2463b0bcaa87ae7043cac107b62abd65efa673100888860ce81a6ee7fdc2e940
IE_DRIVER_ARCH=x64
```

NOTE: Internet Explorer 64bit is slightly faster than 32bit.

### Local + Docker

The build process is much faster if kvm acceleration is available and easier to
debug if system image build is performed on the host and then system image is
passed to Docker build context to finalize the image.

The process should take around 45-60 mins.

Put Windows XP installation ISO file into `files` directory.

These dependencies need to be installed to build on macOS host:

```sh
# run the build script
brew install qemu coreutils gnu-sed cdrtools p7zip
# see the installation progress using vnc viewer (will be automatically launched)
brew install tiger-vnc
```

These dependencies need to be installed to build on Debian host:

```sh
# run the build script
apt-get install -y qemu-kvm genisoimage p7zip-full
# see the installation progress using vnc viewer (will be automatically launched)
apt-get install -y tigervnc-viewer
```

Local build process has these steps:

* generate local build scripts (shell and docker files)
* build system image using shell script
* build docker image using system image produced by shell script

Generate local build scripts:

```sh
./local-configure.sh {PLATFORM}
```

Follow instructions provided by shell script.

Example instruction for `wxp32` platform:

```
Review produced local build scripts (IMPORTANT):
    less ./local-build.wxp32.sh
    less ./local-build.wxp32.docker

Run local build script:
    PRODUCT_KEY=ABCDE-ABCDE-ABCDE-ABCDE-ABCDE IE_VERSION=X ./local-build.wxp32.sh

Finish in Docker:
    docker build --build-arg IE_VERSION=X -f local-build.wxp32.docker -t wxp32-ieX build.wxp32
```

QEMU screen will be available on VNC 5900 port by default during local build so
you could see installation progress. Port could be changed using `VNC_PORT`
environment variable passed to local build script.

## Running

Run container with VNC and Selenium Node:

```bash
docker run -d -p 5900:5900 -p 5555:5555 --cap-add=NET_ADMIN {IMAGE_NAME}
```

Example (running two Selenium Nodes with Selenium Hub):

```bash
# run first Selenium Node reachable by http://selenium-node-1.domain.com:5555
docker run \
  -d \
  -p 5900:5900 \
  -p 5555:5555 \
  -e HUB_HOST=http://selenium-hub.domain.com:4444 \
  -e REMOTE_HOST=http://selenium-node-1.domain.com:5555 \
  --cap-add=NET_ADMIN \
  wxp64-ie7

# run second Selenium Node reachable by http://selenium-node-2.domain.com:5556
docker run \
  -d \
  -p 5901:5900 \
  -p 5556:5555 \
  -e HUB_HOST=http://selenium-hub.domain.com:4444 \
  -e REMOTE_HOST=http://selenium-node-2.domain.com:5556 \
  --cap-add=NET_ADMIN \
  wxp64-ie7
```

Options:

- `--cap-add=NET_ADMIN` - Required to make network access working inside QEMU guest.
- `--privileged` - Could be used instead of `--cap-add=NET_ADMIN` but is not recommended.
- `--device=/dev/kvm` - Enable nested kvm virtualization if available.
- `-p {hostPort}:{guestPort}` - Forward port to container.
  - `5900` is used by VNC by default.
  - `5555` is used by Selenium node by default.
- `-e {varName}={varValue}` - Pass environment variable to container.
  - VNC options:
    - `VNC_DISABLED` - Set to `0` to disable VNC (enabled by default).
  - Selenium options:
    - `SE_HUB` - Selenium Hub public URL including port like `http://selenium-hub.domain.com:4444`.
    - `REMOTE_HOST` - Selenium Node public URL including port like `http://selenium-node-1.domain.com:5555`.
      - This value is auto discovered if container is running on ECS.
  - Browser options:
    - `BROWSER_MAX_INSTANCES` - Set max number of browser instances allowed to run
      at the same time (just one by default). It is recommended to set appropriate
      `QEMU_RAM` value in the case if this value is changed.
  - QEMU options:
    - `QEMU_RAM` - Set amount of RAM reserved for guest (512MB by default).

Multiple containers could be run using different VNC and Selenium ports.

Use official Selenium Docker images to run Selenium Hub:
https://github.com/SeleniumHQ/docker-selenium

## FAQ

* Q: Why does this script check SHA256 for all files?
* A: For security purposes script doesn't trust files downloaded from internet.

* Q: Why VGA driver is different for Windows XP 32 bit and 64 bit Windows?
* A: Windows XP 64 bit and 32 bit have different set of integrated drivers and
  some virtio drivers are just not available for Windows XP 64 bit.
  - `qxl` is available only on 32 bit and is breaking VNC, not available by
    default in Homebrew's `qemu` build so local building with this video adapter
    won't work without rebuilding `qemu` on macOS. `qxl` is the fastest video
    adapter.
  - `cirrus` is available only on 32 bit (slow video adapter).
  - `std` is available only on 64 bit (faster than `cirrus` in 10x times).
  - `wmware` is buggy based on publicly available information, requires WMWare
    guest additions.

* Q: Why `virtio` network adapter is not used?
* A: virtio network adapter is very fast however it is not stable, there is a
  very low chance ratio that guest will boot with network access, especially
  on ECS.

* Q: Why TCG acceleration has disabled modern multi-thread emulation?
* A: It doesn't work stable, especially, on Windows XP 64bit causing random
  BSOD STOP 0x000000D1 or 0x0000001E.

* Q: Why QEMU is compiled during build instead of installing using `yum`?
* A: QEMU is significantly outdated in `amzn2` repo and even in `epel` repo.
  Old versions of QEMU could hang during Windows XP 64bit installation.

* Q: Why do you use old version of IE Driver.
* A: This version is tested to be working well with IE 6/7/8 32bit and 64bit.

* Q: Why is this image based on Amazon Linux?
* A: Because it is easier to use it with AWS ECR and ECS.

## Contribution

Feel free to submit a PR for new features or bug fixes (if any).

## License

MIT
