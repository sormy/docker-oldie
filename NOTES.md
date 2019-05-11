# Dev Notes

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

<http://tools.taubenkorb.at/change-screen-resolution/>

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

https://wiki.archlinux.org/index.php/QEMU#Balloon_driver

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
