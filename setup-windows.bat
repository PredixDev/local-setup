@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

GOTO START

:PROCESS_ARGS
IF "%1"=="" (
  ECHO Installing all the tools...
  CALL :INSTALL_EVERYTHING
  GOTO :eof
)
IF NOT "%1"=="" (
  ECHO Installing only tools specified in parameters...
  CALL :INSTALL_NOTHING
)
:loop_process_args
IF "%1"=="" GOTO end_loop_process_args
IF /I "%1"=="/git" SET install[git]=1
IF /I "%1"=="/cf" SET install[cf]=1
IF /I "%1"=="/putty" SET install[putty]=1
IF /I "%1"=="/jdk" SET install[jdk]=1
IF /I "%1"=="/maven" SET install[maven]=1
IF /I "%1"=="/sts" SET install[sts]=1
IF /I "%1"=="/curl" SET install[curl]=1
IF /I "%1"=="/python2" SET install[python2]=1
IF /I "%1"=="/nodejs" SET install[nodejs]=1
SHIFT
GOTO loop_process_args
:end_loop_process_args
GOTO :eof

:CHECK_INTERNET_CONNECTION
ECHO Checking internet connection...
@powershell -Command "(new-object net.webclient).DownloadString('http://www.google.com')" >$null 2>&1
IF NOT %errorlevel% EQU 0 (
  ECHO Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy
  pause
  exit /b %errorlevel%
)
ECHO OK
GOTO :eof

:INSTALL_CHOCO
choco >$null 2>&1
IF %errorlevel% EQU 9009 (
  ECHO Installing chocolatey...
  @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
  CALL :CHECK_FAIL
)
GOTO :eof

:CHOCO_INSTALL
choco install -y --allow-empty-checksums %*
CALL :CHECK_FAIL
GOTO :eof

:CHECK_FAIL
IF NOT %errorlevel% EQU 0 (
  ECHO FAILED
  pause
  exit /b %errorlevel%
)
GOTO :eof

:INSTALL_NOTHING
SET install[git]=0
SET install[cf]=0
SET install[putty]=0
SET install[jdk]=0
SET install[maven]=0
SET install[sts]=0
SET install[curl]=0
SET install[python2]=0
SET install[nodejs]=0
GOTO :eof

:INSTALL_EVERYTHING
SET install[git]=1
SET install[cf]=1
SET install[putty]=1
SET install[jdk]=1
SET install[maven]=1
SET install[sts]=1
SET install[curl]=1
SET install[python2]=1
SET install[nodejs]=1
GOTO :eof

:START
ECHO --------------------------------------------------------------
ECHO This script will install tools required for Predix development
ECHO --------------------------------------------------------------

SET git=0
SET cf=1
SET putty=2
SET jdk=3
SET maven=4
SET sts=5
SET curl=6
SET python2=7
SET nodejs=8

CALL :PROCESS_ARGS %*

CALL :CHECK_INTERNET_CONNECTION
CALL :INSTALL_CHOCO

REM Reload environment variables to make sure the script can find choco
resetvars.vbs
call "%TEMP%\resetvars.bat"

IF %install[git]% EQU 1 CALL :CHOCO_INSTALL git

IF %install[cf]% EQU 1 (
  CALL :CHOCO_INSTALL cloudfoundry-cli

  REM Reload environment variables to make sure the script can find cf
  resetvars.vbs
  call "%TEMP%\resetvars.bat"

  ( cf plugins | findstr "Predix" >$null 2>&1 ) || cf install-plugin -f https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_win64.exe
)

IF %install[putty]% EQU 1 CALL :CHOCO_INSTALL putty
IF %install[jdk]% EQU 1 CALL :CHOCO_INSTALL jdk
REM Using this version because the latest chocolatey package (3.3.3) fails
IF %install[maven]% EQU 1 CALL :CHOCO_INSTALL maven --version 3.2.5
REM TODO - Uncomment once the chocolatey package is fixed
REM IF %install[sts]% EQU 1 CALL :CHOCO_INSTALL springtoolsuite
IF %install[curl]% EQU 1 CALL :CHOCO_INSTALL curl
IF %install[python2]% EQU 1 CALL :CHOCO_INSTALL python2

IF %install[nodejs]% EQU 1 (
  CALL :CHOCO_INSTALL nodejs.install

  REM Reload environment variables to make sure the script can find npm
  resetvars.vbs
  call "%TEMP%\resetvars.bat"

  bower --version >$null 2>&1 || npm install -g bower
  grunt --version >$null 2>&1 || npm install -g grunt-cli
)
