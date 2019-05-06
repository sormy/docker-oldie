@echo off

cd /d c:\provision

echo Disabling driver search on windows update...
reg add "HKLM\Software\Policies\Microsoft\Windows\DriverSearching" /v DontSearchWindowsUpdate /t REG_DWORD /d 1 /f > nul
reg add "HKLM\Software\Policies\Microsoft\Windows\DriverSearching" /v DontPromptForWindowsUpdate /t REG_DWORD /d 1 /f > nul

echo Disabling found new hardware wizard...
reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceInstall\Settings" /v SuppressNewHWUI /t REG_DWORD /d 1 /f > nul

echo Disabling windows update...
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f > nul

echo Disabling system restore...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v DisableSR /t REG_DWORD /d 1 /f > nul

echo Disabling firewall...
reg add "HKLM\Software\Policies\Microsoft\WindowsFirewall\DomainProfile" /v EnableFirewall /t REG_DWORD /d 0 /f > nul
reg add "HKLM\Software\Policies\Microsoft\WindowsFirewall\StandardProfile" /v EnableFirewall /t REG_DWORD /d 0 /f > nul

echo Disabling open file security warnings...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 1 /f > nul

echo Disabling security center alerts...
reg add "HKLM\Software\Microsoft\Security Center" /v AntiVirusDisableNotify /t REG_DWORD /d 1 /f > nul
reg add "HKLM\Software\Microsoft\Security Center" /v FirewallDisableNotify /t REG_DWORD /d 1 /f > nul
reg add "HKLM\Software\Microsoft\Security Center" /v UpdatesDisableNotify /t REG_DWORD /d 1 /f > nul

echo Disabling language bar on taskbar...
reg add "HKCU\Software\Microsoft\CTF\LangBar" /v ShowStatus /t REG_DWORD /d 3 /f > nul

echo Disabling windows xp tour prompt...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Tour" /v RunCount /t REG_DWORD /d 0 /f > nul

echo Disabling IE popup: You are about to view pages over a secure connection
reg add "HKLM\Software\Microsoft\Internet Explorer\Security" /v DisableSecuritySettingCheck /t REG_DWORD /d 1 /f > nul

echo Disabling IE popup: When you send information to the internet it might be possible for others to see that information?
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1601 /t REG_DWORD /d 0 /f > nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1601 /t REG_DWORD /d 0 /f > nul

echo Disabling IE popup: Do you want to turn AutoComplete on?
reg add "HKCU\Software\Microsoft\Internet Explorer\IntelliForms" /v AskUser /t REG_DWORD /d 0 /f > nul

echo Enabling IE TLS 1.0...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v SecureProtocols /t REG_DWORD /d 170 /f > nul

echo Disabling IE first time information bar...
reg add "HKCU\Software\Microsoft\Internet Explorer\InformationBar" /v FirstTime /t REG_DWORD /d 0 /f > nul

echo Disabling IE phishing filter...
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v ShownVerifyBalloon /t REG_DWORD /d 3 /f > nul
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v Enabled /t REG_DWORD /d 0 /f > nul
reg add "HKLM\Software\Microsoft\Internet Explorer\PhishingFilter" /v ShownVerifyBalloon /t REG_DWORD /d 3 /f > nul
reg add "HKLM\Software\Microsoft\Internet Explorer\PhishingFilter" /v Enabled /t REG_DWORD /d 0 /f > nul

echo Disabling IE information bar notification for intranet content...
reg add "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnIntranet /t REG_DWORD /d 0 /f > nul

echo Disabling IE first run wizard...
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v DisableFirstRunCustomize /t REG_DWORD /d 1 /f > nul
reg add "HKCU\Software\Policies\Microsoft\Internet Explorer\Main" /v DisableFirstRunCustomize /t REG_DWORD /d 1 /f > nul

echo Disabling automatic restart on crash...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v AutoReboot /t REG_DWORD /d 0 /f > nul

echo Registering auto start script...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v provision /t REG_SZ /d "c:\provision\start.bat" /f > nul

if exist jre-7u80-windows-i586.exe (
  echo Installing Java 7...
  start /wait jre-7u80-windows-i586.exe /s

  echo Disabling Java 7 auto update...
  reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f > nul
)

if exist IE7-WindowsXP-x86-enu.exe (
  echo Installing Internet Explorer 7...
  start /wait IE7-WindowsXP-x86-enu.exe /passive /norestart
)

if exist IE7-WindowsServer2003-x64-enu.exe (
  echo Installing Internet Explorer 7...
  start /wait IE7-WindowsServer2003-x64-enu.exe /passive /norestart
)

if exist IE8-WindowsXP-KB2936068-x86-ENU.exe (
  echo Installing Internet Explorer 8...
  start /wait IE8-WindowsXP-KB2936068-x86-ENU.exe /passive /norestart
)

if exist IE8-WindowsServer2003-x64-ENU.exe (
  echo Installing Internet Explorer 8...
  start /wait IE8-WindowsServer2003-x64-ENU.exe /passive /norestart
)

echo Shutting down...
shutdown /s /t 0

echo Waiting...
pause
