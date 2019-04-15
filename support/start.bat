@echo off

echo Downloading start script...
copy /y \\10.0.2.4\qemu\start-node.bat c:\selenium\start-node.bat > nul

echo Executing start script...
cd /d c:\selenium
call c:\selenium\start-node.bat
