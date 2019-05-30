@echo off

: windows xp 64bit requires phishing filter to be configured after initial provision
echo Disabling IE phishing filter...
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v ShownVerifyBalloon /t REG_DWORD /d 3 /f > nul
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v Enabled /t REG_DWORD /d 0 /f > nul

: these variables should be set by main script
set SE_LOG_LEVEL={seLogLevel}
set SE_OPTS={seOpts}
set SE_BROWSER={seBrowser}

: starting selenium server node
echo Starting Selenium Server...
java ^
  -Dselenium.LOGGER.level=%SE_LOG_LEVEL% ^
  -Dwebdriver.ie.driver=./IEDriverServer.exe ^
  -jar selenium-server-standalone.jar ^
  %SE_OPTS% ^
  -browser "%SE_BROWSER%"
