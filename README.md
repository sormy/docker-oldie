# Docker with Internet Explorer 6/7/8

Docker image with QEMU, VNC access, Windows XP, IE 6/7/8 and Selenium Server.

Ideal to run integration tests on ancient IE 6/7/8 in cloud or locally.

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
working is to use Windows XP Corporate that doesn't require activation.

## Building

Building QEMU image requires privileged access and this is not available
during docker build phase, so QEMU system image need to be built separately.

macOS dependencies could be installed using brew:

```
brew install qemu coreutils gnu-sed wget cdrtools p7zip tiger-vnc
```

QEMU system image build process is integrated into `build-system-image` script.

Usage:

```
rm -rf build
./build-system-image <PRODUCT_KEY> [IE_VERSION=6] [VNC_PORT=5900]
docker build -t sormy/oldie:{IE_VERSION} .
```

Build Arguments:

- PRODUCT_KEY - Windows XP SP3 Corporate Product Key (required)
- IE_VERSION - Internet Explorer version: 6 (default), 7 or 8

Runtime Arguments:

- VNC_PORT - VNC port to share the screen (default to 5900)

For example, the command below will create `sormy/oldie:7` container:

```
rm -rf build
./build-system-image ABCDE-ABCDE-ABCDE-ABCDE-ABCDE 7
docker build -t sormy/oldie:7 .
```

## Running

Run container:

```
docker run -d -p 5900:5900 -p 5555:5555 --privileged sormy/oldie:7
```

Options:

- `--privileged` - use this options to get hardware virtualization acceleration (if available).
- `-v /dev/shm:/dev/shm` - ?
- `-p {hostPort}:{guestPort}` - forward port to container
  - `5900` is used for VNC by default
  - `5555` is used by Selenium node by default
- `-e {varName}={varValue}` - pass environment variable to container
  - `SELENIUM_PORT` - run selenium node on this port (default to `5555`)
  - `SELENIUM_HUB` - http://selenium-hub.domain.com:4444/grid/register
  - `VNC_PORT` - run VNC screen on this port (default to `5900`, must be not lower than `5900`)
  - `QEMU_RAM` - amount of RAM in MB shared with QEMU instance (default to `512`)

You could run multiple containers, just run them on different ports.

If you don't need to see what is happening on instance using vnc viewer then
just don't forward VNC port.

## FAQ

Q: Why does this script check SHA256 for all files?
A: For security purposes the script doesn't trust files downloaded from internet.

Q: Why each container can run only single instance of Internet Explorer.
A. Internet Explorer doesn't have an option to isolate sessions so for stability
   it is better to use one container for just one test.

## Contribution

Feel free to submit a PR for new features or/and bug fixes (if any).

These are features I think could be valuable for this project:

- VNC password
- noVNC
- IE 5.5 (Windows 98 SE)
- speedup windows xp (disable unneeded features and services)
- support different qemu vga: std, cirrus, wmware, qxl
- allow to use other windows xp images?
- set screen resolution?
- set IE home page?

## License

MIT
