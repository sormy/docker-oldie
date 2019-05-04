@echo off

echo Mounting Z: drive...
net use z: \\10.0.2.4\qemu /persistent:no > nul

echo Downloading start script...
copy /y z:\start-node.bat c:\provision\start-node.bat > nul

echo Executing start script...
cd /d c:\provision
call c:\provision\start-node.bat
