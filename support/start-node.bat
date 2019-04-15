@echo off

: these variables should be set by main script
set SELENIUM_PORT={seleniumPort}
set SELENIUM_EXTRA_ARGS={seleniumExtraArgs}

: read internet explorer version directly from registry
: IE_VERSION will have full version like A.B.C.D
: IE_MAJOR_VERSION will have only major version like A
for /f "skip=4 tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer" /v Version') do set IE_VERSION=%%a
for /f "tokens=1 delims=." %%a in ("%IE_VERSION%") do set IE_MAJOR_VERSION=%%a

echo Internet Explorer version: %IE_MAJOR_VERSION% (%IE_VERSION%)

echo Starting Selenium Server...
java -Dselenium.LOGGER.level=WARNING ^
  -Dwebdriver.ie.driver=./IEDriverServer.exe ^
  -jar selenium-server-standalone-2.46.0.jar ^
  -port %SELENIUM_PORT% %SELENIUM_EXTRA_ARGS% ^
  -browser "browserName=internet explorer,version=%IE_MAJOR_VERSION%,platform=WINDOWS,maxInstances=1"
