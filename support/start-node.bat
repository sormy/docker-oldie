@echo off

: windows xp 64bit requires phishing filter to be configured after initial provision
echo Disabling IE phishing filter...
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v ShownVerifyBalloon /t REG_DWORD /d 3 /f > nul
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v Enabled /t REG_DWORD /d 0 /f > nul

: these variables should be set by main script
set SELENIUM_PORT={seleniumPort}
set SELENIUM_EXTRA_ARGS={seleniumExtraArgs}
set SELENIUM_INSTANCES={seleniumInstances}

: read internet explorer version directly from registry
: IE_VERSION will have full version like A.B.C.D
: IE_MAJOR_VERSION will have only major version like A
reg query "HKLM\Software\Microsoft\Internet Explorer" /v Version | findstr /rc:REG_SZ > ie-version-reg.txt
for /f "tokens=3" %%a in (ie-version-reg.txt) do set IE_VERSION=%%a
del /f /q ie-version-reg.txt
for /f "tokens=1 delims=." %%a in ("%IE_VERSION%") do set IE_MAJOR_VERSION=%%a

echo Internet Explorer version: %IE_MAJOR_VERSION% (%IE_VERSION%)

: add Java to PATH (needed for Windows XP x64)
set PATH=%PATH%;%ProgramFiles%\Java\jre7\bin;%ProgramFiles(x86)%\Java\jre7\bin

echo Starting Selenium Server...
java -Dselenium.LOGGER.level=WARNING ^
  -Dwebdriver.ie.driver=./IEDriverServer.exe ^
  -jar selenium-server-standalone-2.46.0.jar ^
  -port %SELENIUM_PORT% %SELENIUM_EXTRA_ARGS% ^
  -browser "browserName=internet explorer,version=%IE_MAJOR_VERSION%,platform=WINDOWS,maxInstances=%SELENIUM_INSTANCES%"
