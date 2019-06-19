# Dev Notes

## Improvement Ideas

- Disable PXE boot delay
- Mark ethernet and storage devices as not external
- Disable screensaver
- Remove desktop walpaper
- Option to set windows classic theme
- Share clipboard over VNC (qemu spice only?)
- Set screen resolution and etc in runtime?
- Automatically install drivers if video or network adapater has changed on
  Windows XP 32bit (Windows XP 64bit can do that by default)
- Do one login after setup to make next login much faster
- Web-based viewer (noVNC, for example)
- Add VNC authentication (password, for example)
- Option to disable Selenium Server
- Show network icon for network adapter?
- Option to install custom trusted SSL certificates in runtime
- Allow to use other windows xp images (need to test)?
- Speedup windows xp (disable unneeded features and services)
- Dubug installation process in Docker (record VNC video to file?)
- IE 5.5 (using Windows 2000 Pro)
- ~~Add Docker HEALTHCHECK~~
- Test different accel values: kvm, xen, hax
- QEMU balloon driver and service
- QEMU guest agent
- ~~AWS ECS auto discovery~~
- Set true UTC time inside guest without Dayling Saving.
- Disable swap.
- Disable browsing history for IE.
- Private profiles for IE8.
- Migrate to Amazon Coretto OpenJDK build.
- Get rid of samba and download start-node.bat from the host using http,
  socat could be used to serve files: https://stackoverflow.com/questions/29739901/socat-fake-http-server-use-a-file-as-server-response

## Detect IE version on the fly

```bat
: read internet explorer version directly from registry
: IE_VERSION will have full version like A.B.C.D
: IE_MAJOR_VERSION will have only major version like A
reg query "HKLM\Software\Microsoft\Internet Explorer" /v Version | findstr /rc:REG_SZ > ie-version-reg.txt
for /f "tokens=3" %%a in (ie-version-reg.txt) do set IE_VERSION=%%a
del /f /q ie-version-reg.txt
for /f "tokens=1 delims=." %%a in ("%IE_VERSION%") do set IE_MAJOR_VERSION=%%a

echo Internet Explorer version: %IE_MAJOR_VERSION% (%IE_VERSION%)
```

## Enable qxl in qemu

```
yum install -y libcacard spice-server-devel
QEMU_CONF_OPTS="... --enable-spice"
cp -v virtio/{viostor,qxl,NetKVM}/...
yum uninstall -y spice-server-devel
```

## Mark devices as not external

QEMU 4.x marks ethernet and storage devices as conneced to USB with hot plug.

https://www.robvanderwoude.com/subinacl.php
https://download.microsoft.com/download/1/7/d/17d82b72-bc6a-4dc8-bfaa-98b37b22b367/subinacl.msi

Checklist:

- Update `Dockerfile`
- Update `once.bat`
- `subinacl` could be used to grant access to registry section because this one is rectricted by default
- Test on different network and storage devices and OSes

```bat
if exist subinacl.msi (
  echo Installing subinacl...
  start /wait msiexec /i subinacl.msi /passive
  set "PATH=%PATH%;%ProgramFiles%\Windows Resource Kits\Tools;%ProgramFiles(x86)%\Windows Resource Kits\Tools"
)

echo Disabling eject hard disk (viostor)
reg add "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_1AF4&DEV_1000&SUBSYS_00011AF4&REV_00\3&13c0b0c5&0&90" /v Capabilities /t REG_DWORD /d 2 /f > nul

echo Disabling eject network card (virtio)
reg add "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_1AF4&DEV_1002&SUBSYS_00051AF4&REV_00\3&13c0b0c5&0&18" /v Capabilities /t REG_DWORD /d 2 /f > nul

echo Disabling eject network card (e1000)
reg add "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_8086&DEV_100E&SUBSYS_11001AF4&REV_03\3&13c0b0c5&0&18" /v Capabilities /t REG_DWORD /d 2 /f > nul
```

## Disable desktop walpaper

This need to be executed on first login:

```bat
echo Disabling desktop walpaper...
reg add "HKCU\Software\Microsoft\Internet Explorer\Desktop\General" /v BackupWallpaper /t REG_SZ /d "" /f > nul
reg add "HKCU\Software\Microsoft\Internet Explorer\Desktop\General" /v Wallpaper /t REG_SZ /d "" /f > nul
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "" /f > nul
```

## Disable screen saver

This need to be executed on first login:

```bat
echo Disabling screen saver...
reg delete "HKCU\Control Panel\Desktop" /v SCRNSAVE.EXE /f > nul
reg add "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_DWORD /d 0 /f > nul
```

## Change resolution in runtime

- <http://tools.taubenkorb.at/change-screen-resolution/>
- http://qres.sourceforge.net/

## Disable PXE boot delay

Passing `romfile=` to `-nic` should fix the issue.

## noVNC

```sh
apt-get install git

curl -sL https://deb.nodesource.com/setup_11.x | bash -
apt-get install -y nodejs

mkdir -p /opt && cd /opt
git clone https://github.com/novnc/noVNC.git
cd /opt/noVNC
git checkout v1.1.0
npm install
./utils/use_require.js --with-app --as commonjs
npm install http-server -g
```

## Balloon driver

Balloon driver can release unused guest OS memory back to host.

This feature requires more testing:

- https://wiki.archlinux.org/index.php/QEMU#Balloon_driver
- https://www.linux-kvm.org/page/Projects/auto-ballooning
- https://pve.proxmox.com/wiki/Dynamic_Memory_Management

QEMU option (entrypoint and Dockerfile): `-device virtio-balloon`

Installation from virtio drivers iso:

```bash
DRIVER_PATH=`[ "$WIN_ARCH" = 32 ] && echo "xp/x86" || echo "2k3/amd64"`
cp -v virtio-win/Balloon/$DRIVER_PATH/* 'install/$oem$/$1/drivers'
```

Service installation in `once.bat`:

```bat
cd /d c:\drivers

if exist blnsvr.exe (
  echo Installing QEMU balloon service...
  start /wait blnsvr.exe /i
)
```

## Guest agent

https://wiki.qemu.org/index.php/Features/GuestAgent

## Windows 2000

This image build script is partially complete but some things still need an action:

- IEDriverServer requires additional fixes to be stable
- (optional) get rid of Window XP reg.exe file
- (optional) separate windows 2000 and windows xp support files
- (optional) extract gdiplus.dll from provided by MS installer on the fly
- (optional) extract psshutdown.exe from PSTools.zip on the fly
- (optional) download ie6sp1en.zip on the fly

What works:

- Full unattended setup, no questions, auto login
- Registry is fixed to not ask dump questions
- Manual driver :-) is working well (over VNC)

Prerequisites (current version):

- ie6sp1en.zip with ie6sp1en folder containing ie6setup.exe and other files
  downloaded from https://archive.org/download/IE6SP1/IE6%20SP1.zip
  (Microsoft doesn't allow to download this file these days)
- IEDriverServer_Win32_2.40.0_w2k_1.0.zip - archived IEDriverServer.exe
  built from https://github.com/sormy/selenium-w2k using Visual Studio 2008 Pro
  (vanilla IEDriverServer was never working on Windows 2000, so specially fixed
  version needed to make it work)
- gdiplus_kb975337.zip with gdiplus.dll extracted from
  https://download.microsoft.com/download/a/b/c/abc45517-97a0-4cee-a362-1957be2f24e1/WindowsXP-KB975337-x86-ENU.exe
  (IEDriverServer depends on it)
- jre-6-windows-i586.exe downloaded from Oracle website (free registration required)
  (the highest java version that is working on Windows 2000)
- psshutdown_2.52.zip - archived psshutdown.exe extracted from PsTools
  https://download.sysinternals.com/files/PSTools.zip
  (shutdown.exe is not available on Windows 2000)
- reg_wxp32sp3en.zip - archived reg.exe grabbed from Windows XP Pro SP3.
  (reg.exe is not available on Windows 2000)
- en_win2000_pro_sp4.iso - Windows 2000 SP4 Pro English ISO.

Workarounds:

- reg.exe is not available on Windows 2000, copied from Windows XP.
- shutdown.exe is not available on Windows 2000, psshutdown.exe is used instead.
- IEDriverServer never worked on Windows 2000, partially fixed here:
  https://github.com/sormy/selenium-w2k
- Java 6 is the latest Java available for Windows 2000, the latest compatible
  Selenium Server is v2.40.0.

Notes (not sure if will be needed):

- Windows Installer 2.0 doesn't support /passive /norestart.
  https://download.microsoft.com/download/1/4/7/147ded26-931c-4daf-9095-ec7baf996f46/WindowsInstaller-KB893803-v2-x86.exe
  WindowsInstaller-KB893803-v2-x86.exe /passive /norestart

## Links

* https://github.com/kevinwallace/qemu-docker
* http://showcase.netins.net/web/giftitems/BEGINNERS/10_%20WINNT_SIF%20Reference_19.htm
* http://unattended.sourceforge.net/timezones.php
* https://www.svrops.com/svrops/documents/xpunattend.htm
* https://support.microsoft.com/en-ca/help/155197/howto-unattended-setup-parameters-for-unattend-txt-file
* https://qemu.weilnetz.de/doc/qemu-doc.html#SVGA-graphic-modes-support
* https://en.wikibooks.org/wiki/QEMU/Networking#Redirecting_ports
* https://batchloaf.wordpress.com/2013/02/12/simple-trick-for-sending-characters-to-a-serial-port-in-windows/
* https://help.ubuntu.com/community/WindowsXPUnderQemuHowTo
* https://wiki.archlinux.org/index.php/QEMU#Change_Existing_Windows_VM_to_use_virtio
* https://wiki.gentoo.org/wiki/QEMU/Options
* https://www.suse.com/documentation/sles11/book_kvm/data/cha_qemu_running_devices.html
* https://jurik-phys.net/files/kvm/
* https://www.linux-kvm.org/page/WindowsGuestDrivers/viostor/installation
* https://b3n7s.github.io/update/2016/06/08/windows-xp-on-qemu.html
