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
- OpenJDK 8 32bit (ojdkbuild)
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

OEM and Retail editions won't work because they require activation that should
be performed just once. Container will try to do activation each time new
container is started so eventually it will lead to phone activation prompt
that can't be processed automatically.

Images without service packs should work well but it was not tested.

Images with other primary system language should also work but it was not tested.

If you would like to use your Windows installation ISO then copy ISO to `files`
directory and provide `WIN_ISO_FILE`, `WIN_ISO_SHA256` build arguments to
Docker during the build.

Windows XP has different versions IE7/8 installers depending on language, so
updated `IE_INSTALL_URL` and `IE_INSTALL_SHA256` need to be also passed.

You could always confirm hashes for official MSDN distributions here:

* https://msdn.lol-inter.net/
* http://www.heidoc.net/php/myvsdump.php

## Available Profiles

- `wxp32-ie6` - Windows XP 32bit + Internet Explorer 6 + IE Driver 32bit
- `wxp32-ie7` - Windows XP 32bit + Internet Explorer 7 + IE Driver 32bit
- `wxp32-ie8` - Windows XP 32bit + Internet Explorer 8 + IE Driver 32bit
- `wxp64-ie6` - Windows XP 64bit + Internet Explorer 6 + IE Driver 32bit
- `wxp64-ie6-64` - Windows XP 64bit + Internet Explorer 6 + IE Driver 64bit
- `wxp64-ie7` - Windows XP 64bit + Internet Explorer 7 + IE Driver 32bit
- `wxp64-ie7-64` - Windows XP 64bit + Internet Explorer 7 + IE Driver 64bit
- `wxp64-ie8` - Windows XP 64bit + Internet Explorer 8 + IE Driver 32bit
- `wxp64-ie8-64` - Windows XP 64bit + Internet Explorer 8 + IE Driver 64bit

All profiles are generated from `wxp32-ie6` with `./build-profiles.sh`.

NOTE: Internet Explorer 64bit is slightly faster than 32bit.

Java 64bit doesn't add performance but eats more RAM so there is no profile
for it but you can use any OpenJDK 8 MSI x86 or x64 installer (on 64 bit OS).
Just pass `JAVA_MSI_URL` and `JAVA_MSI_SHA256` build arguments to docker build
command if you would like to use another OpenJDK build.

List of OpenJDK builds: https://github.com/akullpp/awesome-java#jvm-and-jdk

## Building

### Docker Only

Docker doesn't have an option to build image with privileged access and port
forwarding so VNC and hardware acceleration for emulation won't be available
during the build.

The process should take around 45-60 mins.

Two things to build the image:

- Copy previosly legally obtained Windows XP installation ISO into `files`
  directory.
- Pass previosly legally obtained Windows XP product key as `PRODUCT_KEY` build
  argument.

Put Windows XP installation ISO file into `files` directory.

Usage:

```sh
docker build \
  --build-arg PRODUCT_KEY={PRODUCT_KEY} \
  -f Dockerfile.{PROFILE} \
  -t {IMAGE_NAME} .
```

Example (IE7 running on Windows XP 32bit):

```sh
docker build \
  --build-arg PRODUCT_KEY=AAAAA-BBBBB-CCCCC-DDDDD-EEEEE \
  -f Dockerfile.wxp32-ie7 \
  -t wxp32-ie7 .
```

Example (IE7 running on Windows XP 64bit):

```sh
docker build \
  --build-arg PRODUCT_KEY=AAAAA-BBBBB-CCCCC-DDDDD-EEEEE \
  -f Dockerfile.wxp64-ie7 \
  -t wxp64-ie7 .
```

Build files have a lot of build arguments but almost all of them have reasonable
defaults that are not recommended to change unless you know what you are doing.

While VNC is not available during build there is stil an option to take a
screenshot from container that is running QEMU:

```sh
# (host) identify container ID
docker ps

# (host) open shell connection to container
docker exec -it {ContainerID} bash

# (container) install Net::VNC perl application all all dependencies
yum install -y perl-devel
cpan install YAML
cpan install Module::Build
yum install -y imlib2 imlib2-devel
cpan install Image::Imlib2
cpan install Net::VNC

# (container) take a screenshot (using default options)
vnccapture

# (host) copy produced screenshot from container to host
docker cp {ContainerID}:/opt/qemu/snapshot0001.png .

# (host) open image using image viewer
open snapshot0001.png
```

### Local + Docker

The build process is much faster if KVM acceleration is available and easier to
debug if VNC is available (see Windows installation progress). Below are
instructions how to build system QEMU image on the host then pass it to Docker
build context to finalize Docker image.

The process should take around 45-60 mins.

Two things to build the image:

- Copy previosly legally obtained Windows XP installation ISO into `files`
  directory.
- Pass previosly legally obtained Windows XP product key as `PRODUCT_KEY`
  environment variable to local build shell script.

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
./local-configure.sh {PROFILE}
```

Follow instructions provided by shell script.

Example instruction for `wxp32-ie7` profile:

```
Review produced local build scripts (IMPORTANT):
    less ./local-build.wxp32-ie7.sh
    less ./local-build.wxp32-ie7.docker

Run local build script:
    PRODUCT_KEY=ABCDE-ABCDE-ABCDE-ABCDE-ABCDE ./local-build.wxp32-ie7.sh

Finish in Docker:
    docker build -f local-build.wxp32-ie7.docker -t wxp32-ie7 build.wxp32-ie7
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
    - `SE_HUB` - Selenium Hub public URL including port like `http://selenium-hub.domain.com:4444`. Protocol, hostname or ip address and port
    are mandatory. Even if http port is 80 it must be explicitly passed.
      If this value is not passed than Selenium Server will start standalone node.
    - `SE_REMOTE_HOST` - Selenium Node public URL including port like `http://selenium-node-1.domain.com:5555`.
      - This value is auto discovered if container is running on ECS.
    - `SE_OPTS` - Other Selenium Server options to pass to Selenium Node.
      The list of available options you could see in Selenium Server help:
      `java selenium-server.jar -role node -h`
    - `SE_LOG_LEVEL` - Selenium Server log level: `OFF`, `SEVERE`,
      `WARNING` (default), `INFO`, `DEBUG` or `ALL`.
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

### Why does this script check hash for all files?

For security purposes script doesn't trust files downloaded from internet.

### Why VGA driver is different for Windows XP 32 bit and 64 bit Windows?

Windows XP 64 bit and 32 bit have different set of integrated drivers and
some virtio drivers are just not available for Windows XP 64 bit.

- `qxl` is available only on 32 bit and is breaking VNC, not available by
  default in Homebrew's `qemu` build so local building with this video adapter
  won't work without rebuilding `qemu` on macOS. `qxl` is the fastest video
  adapter.
- `cirrus` is available only on 32 bit (slow video adapter).
- `std` is available only on 64 bit (faster than `cirrus` in 10x times).
- `wmware` is buggy based on publicly available information, requires WMWare
  guest additions.

### Why `virtio` network adapter is not used?

Virtio network adapter is very fast however it is not stable (at least on XP),
there is a very low chance ratio that guest will boot with network access,
especially on ECS. `rtl8139` 100mbit driver is available in Windows XP 32bit
and `e1000` 1000mbit driver is available in Windows XP 64bit.

### Why TCG acceleration has disabled modern multi-thread emulation?

It doesn't work stable, especially, on Windows XP 64bit causing random
BSOD STOP 0x000000D1 or 0x0000001E. On Windows XP 32bit it is more stable
but still could cause random BSOD.

### Why QEMU is compiled during build instead of installing using `yum`?

QEMU is significantly outdated in `amzn2` repo and even in `epel` repo.
Old versions of QEMU could hang during Windows XP 64bit installation.
It is easier to maintain this image if QEMU version will be locked to
specific version that is well-known to work without issues.

### Why do you use old version of IE Driver.

This version is tested to be working well with IE 6/7/8 32bit and 64bit
and Windows XP.

### Why is this image based on Amazon Linux?

Because it is easier to use it with AWS ECR and ECS.

## Contribution

Feel free to submit a PR for new features or bug fixes (if any).

## License

MIT
