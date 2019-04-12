@echo off

echo Start Selenium Server
cd /d c:\selenium
copy /y \\10.0.2.4\qemu\start-node.bat c:\selenium\start-node.bat > nul
call c:\selenium\start-node.bat
