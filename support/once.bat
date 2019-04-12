@echo off

set IE_VERSION={ieVersion}

echo Disable driver search on Windows Update
reg add "HKLM\Software\Policies\Microsoft\Windows\DriverSearching" /v DontSearchWindowsUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\DriverSearching" /v DontPromptForWindowsUpdate /t REG_DWORD /d 1 /f

echo Disable Windows Update
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f

echo Disable System Restore
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v DisableSR /t REG_DWORD /d 1 /f

echo Disable Firewall
reg add "HKLM\Software\Policies\Microsoft\WindowsFirewall\DomainProfile" /v EnableFirewall /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\WindowsFirewall\StandardProfile" /v EnableFirewall /t REG_DWORD /d 0 /f

echo Disable Security Center Alerts
reg add "HKLM\Software\Microsoft\Security Center" /v AntiVirusDisableNotify /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Security Center" /v FirewallDisableNotify /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Security Center" /v UpdatesDisableNotify /t REG_DWORD /d 1 /f

echo Disable the Windows XP Tour prompt
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Tour" /v RunCount /t REG_DWORD /d 0 /f

echo Disable IE popup: You are about to view pages over a secure connection
reg add "HKLM\Software\Microsoft\Internet Explorer\Security" /v DisableSecuritySettingCheck /t REG_DWORD /d 1 /f

echo Enable IE TLS 1.0
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v SecureProtocols /t REG_DWORD /d 170 /f

echo Disable IE first time information bar
reg add "HKCU\Software\Microsoft\Internet Explorer\InformationBar" /v FirstTime /t REG_DWORD /d 0 /f

echo Disable IE information bar notification for intranet content
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v ShownVerifyBalloon /t REG_DWORD /d 3 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Internet Explorer\PhishingFilter" /v ShownVerifyBalloon /t REG_DWORD /d 3 /f
reg add "HKLM\Software\Microsoft\Internet Explorer\PhishingFilter" /v Enabled /t REG_DWORD /d 0 /f

echo Disable IE Phishing Filter
reg add "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnIntranet /t REG_DWORD /d 0 /f

echo Enable Selenium auto start
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v selenium /t REG_SZ /d "c:\selenium\start.bat" /f

cd /d c:\selenium

echo Install Java 7
start /wait jre-7u80-windows-i586.exe /s

if "%IE_VERSION%"=="7" (
  echo Install Internet Explorer 7
  start /wait IE7-WindowsXP-x86-enu.exe /passive /norestart
)

if "%IE_VERSION%"=="8" (
  echo Install Internet Explorer 8
  start /wait IE8-WindowsXP-KB2936068-x86-ENU.exe /passive /norestart
)

echo Shutdown
shutdown /s /t 0
