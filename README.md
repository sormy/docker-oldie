# Docker with Internet Explorer 6/7/8

Docker image with QEMU, VNC access, Windows XP, IE 6/7/8 and Selenium Server.

Ideal to run integration tests on ancient IE 6/7/8 in cloud or locally.

The build script is designed to use official windows xp msdn iso image. It will
unpack image, inject drivers and configuration and will install it as qemu guest.

The build script will also install Java, Selenium Server, Internet Explorer 7/8
(if requested) and will tune registry to make instance easier to use with Selenium.

## Prerequisites

### Windows XP ISO

Recommended Windows XP ISO image:

* Name: Windows XP Pro SP3 x86 English Corporate
* File: en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso
* SHA256: fd8c8d42c1581e8767217fe800bfc0d5649c0ad20d754c927d6c763e446d1927
* Put into `files` directory

### Java RE

Java RE 7.x that is compatible with Windows XP is not available for downloading
without registering Oracle account these days. You could download file manualy.

* Name: Oracle Java RE 7
* File: jre-7u80-windows-i586.exe
* SHA256: a87adf22064e2f7fa6ef64b2513533bf02aa0bf5265670e95b301a79d7ca89d9
* Put into `files` directory

## Legal Rights

Internet Explorer 6/7/8 were released for Windows XP and not available for
Windows Vista/7/8/8.1/10.

The only legal way to run Windows XP these days is to use right to downgrade:
https://download.microsoft.com/download/6/8/9/68964284-864d-4a6d-aed9-f2c1f8f23e14/downgrade_rights.pdf

> For Windows 10 licenses acquired though Commercial Licensing, you may downgrade
> to any prior version of the licensed Windows edition.

Windows XP activation services are down these days and the only way to get it
working is to use Windows XP Corporate Edition that doesn't require activation.

## Building inside container

Docker doesn't have an option to build image with privileged access so
port forwarding and hardware acceleration for emulation won't be available
during the build.

That mean that image build won't be fast and there will be no way to see
installation progress using VNC viewer.

The process is running around 60 mins on Macbook Pro 2017 Core i7.

Usage:

```
docker build \
  --build-arg PRODUCT_KEY={PRODUCT_KEY} \
  --build-arg IE_VERSION={IE_VERSION} \
  -t sormy/oldie:{IE_VERSION} .
```

Build Arguments:

- `PRODUCT_KEY` - Windows XP SP3 Corporate Product Key (required)
- `IE_VERSION` - Internet Explorer version: `6` (default), `7` or `8`
- `QEMU_VGA` - `std`, `cirrus` (default), `wmware`, `qxl`
  - `std` - no driver for window xp or I did not find it
  - `cirrus` - Cirrus Logic 5446, windows xp has driver for it
  - `vmware` - there is a driver from VMWare guest ISO but vmware support sometimes
    is not enabled in qemu buld (like on debian:buster, for example)
  - `qxl` - there is a driver but qxl support sometimes is not enable in qemu build
    (like on homebrew macOS, for example), and it also doesn't work well with VNC
    connected to the screen (vnc viewer consistently loosing the connection)
- `SCREEN_WIDTH` - screen width (1024 by default)
- `SCREEN_HEIGHT` - screen height (768 by default)
- `COLOR_DEPTH` - color depth (24 bits by default)
- `REFRESH_RATE` - refresh rate (60 Hz by default)

## Building on host (local)

The building process is much faster and easier to debug if system image build
is performed on host and then system image is copied into container.

The process is running around 45 mins on Macbook Pro 2017 Core i7.

These dependencies need to be installed to build on macOS host:

```
# install intel hardware acceleration kernel module
brew cask install intel-haxm
# load haxm kernel module
sudo kextload /Library/Extensions/intelhaxm.kext
# run the build script
brew install qemu coreutils gnu-sed wget cdrtools p7zip
# see the installation progress using vnc viewer (will be automatically launched)
brew install tiger-vnc
```

These dependencies need to be installed to build on Debian/Ubuntu:

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
PRODUCT_KEY={PRODUCT_KEY} IE_VERSION={IE_VERSION} ./local-build
# build docker image
cp -v Dockerfile.local build/Dockerfile
cd build && docker build -t sormy/oldie:{IE_VERSION} . && cd -
```

Script `local-configure` will parse `Dockerfile` and convert to shell script on
the fly that will be executed locally to build system image.

QEMU screen will be available on VNC 5900 port by default during the build.

You could pass additional build arguments (see previous section) using shell
environment variables, the same as `PRODUCT_KEY` and `IE_VERSION`.

## Running

Run container:

```
docker run -d -p 5900:5900 -p 5555:5555 --privileged sormy/oldie:7
```

Options:

- `--privileged` - required to make network access working inside QEMU guest
- `-v /dev/kvm:/dev/kvm` - enable nested kvm virtualization if available
- `-p {hostPort}:{guestPort}` - forward port to container
  - `5900` is used for VNC by default
  - `5555` is used by Selenium node by default
- `-e {varName}={varValue}` - pass environment variable to container
  - `SELENIUM_PORT` - run selenium node on this port (default to `5555`)
  - `SELENIUM_HUB` - http://selenium-hub.domain.com:4444/grid/register
  - `VNC_PORT` - run VNC screen on this port (default to `5900`, must be not lower than `5900`)
  - `QEMU_RAM` - amount of RAM in MB shared with QEMU instance (default to `512`)
  - `QEMU_VGA` - the vga could be changed after image creation, however, it will require
    manual action to invoke driver installation in guest os.

You could run multiple containers, just run them on different ports.

If you don't need to see what is happening on instance using vnc viewer then
just don't forward VNC port.

## FAQ

* Q: Why does this script check SHA256 for all files?
* A: For security purposes the script doesn't trust files downloaded from internet.

* Q: Why each container can run only single instance of Internet Explorer.
* A: Internet Explorer doesn't have an option to isolate sessions so for stability
  it is better to use one container for just one test.

## Contribution

Feel free to submit a PR for new features or/and bug fixes (if any).

These are features I think could be valuable for this project:

- Share clipboard over VNC, should be fixable with spice guest tools being installed
- Set screen resolution and etc in runtime? <http://tools.taubenkorb.at/change-screen-resolution/>
- Automatically install drivers for video adapater if QEMU_VGA has changed.
- Do one login after setup to make next login much faster
- Web-based viewer (noVNC, for example)
- Add vnc authentication (password, for example)
- Show network icon?
- Option to install custom trusted SSL certificates in runtime
- Allow to use other windows xp images?
- Speedup windows xp (disable unneeded features and services)
- Docker can't forward ports during build but we still could take screenshots
  during then build. Will need to provide instructions how to debug issues during
  container build.
- IE 5.5 (using Windows 2000 Pro)
- Add Docker HEALTHCHECK
- Add -accel to qemu on different stages (container build, local build, runtime)
  and test how does it work with kvm, xen, hax

## License

MIT
