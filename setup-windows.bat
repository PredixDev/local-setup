@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

CALL :CHECK_FAIL

REM Reload environment variables to make sure the script can find choco
resetvars.vbs
call "%TEMP%\resetvars.bat"

choco install -y cloudfoundry-cli
CALL :CHECK_FAIL
choco install -y git
CALL :CHECK_FAIL
choco install -y jdk
CALL :CHECK_FAIL
choco install -y maven
CALL :CHECK_FAIL
choco install -y nodejs.install
CALL :CHECK_FAIL
choco install -y curl
CALL :CHECK_FAIL
choco install -y python2
CALL :CHECK_FAIL
choco install -y springtoolsuite
CALL :CHECK_FAIL

REM Reload environment variables to make sure the script can find cf & npm
resetvars.vbs
call "%TEMP%\resetvars.bat"

cf install-plugin https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_win64.exe

npm install -g bower
npm install -g grunt-cli

:CHECK_FAIL
@echo off
if NOT ["%errorlevel%"]==["0"] (
    pause
    exit /b %errorlevel%
)

