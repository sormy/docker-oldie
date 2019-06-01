@echo off

: script could be executed before network address obtained over dhcp so 10s delay is added here
echo Waiting for connection...
ping localhost -n 11 > nul

: detect gateway ip address
for /f "tokens=2 delims={}" %%a in ('
  wmic /locale:ms_409 NICConfig where IPEnabled^="True" get DefaultIPGateway /value ^| findstr /r /v "^$"
') do set "GATEWAY_ADDRESS=%%a"
if not "%GATEWAY_ADDRESS%"=="" set GATEWAY_ADDRESS=%GATEWAY_ADDRESS:"=%

: in worst case scenario we can't really do anything better than that
if "%GATEWAY_ADDRESS%"=="" (
  echo Unable to obtain the gateway address. Press any key to restart...
  pause > nul
  shutdown /r /t 0
)

: generated node start file is located here
echo Mounting Z: drive...
net use z: \\%GATEWAY_ADDRESS%\qemu /persistent:no > nul

: download node start file
echo Downloading start script...
copy /y z:\start-node.bat c:\provision\start-node.bat > nul

: run node start file
echo Executing start script...
cd /d c:\provision
call c:\provision\start-node.bat

: don't close console automatically (wait for keypress)
pause > nul
