@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

echo branch=!BRANCH!
REM SET RESETVARS=https://raw.githubusercontent.com/PredixDev/local-setup/!BRANCH!/resetvars.vbs
SET RESETVARS=https://raw.githubusercontent.com/PredixDev/local-setup/master/resetvars.vbs

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
rem curl is not reliable on windows command window
rem IF /I "%1"=="/curl" SET install[curl]=1
IF /I "%1"=="/nodejs" SET install[nodejs]=1
IF /I "%1"=="/python2" SET install[python2]=1
IF /I "%1"=="/python3" SET install[python3]=1
IF /I "%1"=="/jq" SET install[jq]=1
IF /I "%1"=="/predixcli" SET install[predixcli]=1
IF /I "%1"=="/mobilecli" SET install[mobilecli]=1
IF /I "%1"=="/androidstudio" SET install[androidstudio]=1
SHIFT
GOTO loop_process_args
:end_loop_process_args
SET install[jq]=1
GOTO :eof

:GET_DEPENDENCIES
  ECHO Getting Dependencies
  CALL :DOWNLOAD_TO_FILE !RESETVARS! , %TEMP%\resetvars.vbs
GOTO :eof

:RELOAD_ENV
  "%TEMP%\resetvars.vbs"
  CALL "%TEMP%\resetvars.bat" >$null
  CALL refreshenv
GOTO :eof

:CHECK_INTERNET_CONNECTION
ECHO Checking internet connection...
@powershell -Command "iwr http://bing.com" >$null 2>&1
IF NOT !errorlevel! EQU 0 (
  ECHO Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy.  For detailed info about setting up your proxy please see this tutorial https://www.predix.io/resources/tutorials/tutorial-details.html?tutorial_id=1565
  exit /b !errorlevel!
)
ECHO OK
GOTO :eof

:INSTALL_CHOCO
where choco >$null 2>&1
IF NOT !errorlevel! EQU 0 (
  ECHO Installing chocolatey...
  @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) >$null 2>&1" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
  CALL :CHECK_FAIL
)
GOTO :eof

:CHOCO_INSTALL
SETLOCAL
SET tool=%1
SET cmd=%1
IF NOT "%2"=="" (
  SET cmd=%2
)
where !cmd! >$null 2>&1
IF NOT !errorlevel! EQU 0 (
  choco install -y --allow-empty-checksums %1
  CALL :CHECK_FAIL
  CALL :RELOAD_ENV
) ELSE (
  ECHO %1 already installed
  ECHO.
)
ENDLOCAL & GOTO :eof

:DOWNLOAD_TO_FILE 
  ECHO download to file
  ECHO %~1 %~2
  REM arg1 is URL, arg2 is filename to redirect output to
  @powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $response = iwr -uri %~1; write-output $response.Content | Out-File %~2 ASCII -Width 9999"
  CALL :CHECK_FAIL
  REM echo return from check_fail
GOTO :eof

:DOWNLOAD_BINARY_TO_FILE
  ECHO download binary to file
  ECHO %~1 %~2
  REM arg1 is URL, arg2 is filename to redirect output to
  @powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;  (new-object net.webclient).DownloadFile('%~1','%~2')
  CALL :CHECK_FAIL    
GOTO :eof

:CHECK_FAIL
IF NOT !errorlevel! EQU 0 (
  ECHO FAILED
  ECHO Any changes to the PATH will not take affect unless you reopen a new Admin command window, please open a new window now.
  exit /b !errorlevel!
)
GOTO :EOF

:INSTALL_NOTHING
SET install[git]=0
SET install[cf]=0
SET install[putty]=0
SET install[jdk]=0
SET install[maven]=0
SET install[sts]=0
rem SET install[curl]=0
SET install[nodejs]=0
SET install[python2]=0
SET install[python3]=0
SET install[jq]=0
SET install[predixcli]=0
SET install[mobilecli]=0
SET install[androidstudio]=0
GOTO :eof

:INSTALL_EVERYTHING
SET install[git]=1
SET install[cf]=1
SET install[putty]=1
SET install[jdk]=1
SET install[maven]=1
SET install[sts]=1
rem SET install[curl]=1
SET install[nodejs]=1
SET install[python2]=1
SET install[python3]=1
SET install[jq]=1
SET install[predixcli]=1
SET install[mobilecli]=1
SET install[androidstudio]=0
GOTO :eof


:INSTALL_PREDIXCLI
ECHO.
ECHO Installing predixcli...
where predix >$null 2>&1
IF NOT !errorlevel! EQU 0 (
  ECHO Downloading installer
  CALL :CHOCO_INSTALL 7zip.commandline 7z
  REM get the url of the release file
  CALL :DOWNLOAD_TO_FILE https://api.github.com/repos/PredixDev/predix-cli/releases , predix-cli-output.tmp
  <predix-cli-output.tmp ( jq -r ".[0].assets[0].browser_download_url" >predix-cli-output2.tmp )
  SET /p cli_url=<predix-cli-output2.tmp
  CALL :DOWNLOAD_TO_FILE https://api.github.com/repos/PredixDev/predix-cli/releases , predix-cli-output.tmp

  CALL :DOWNLOAD_BINARY_TO_FILE !cli_url! , predix-cli.tar.gz
  7z x "predix-cli.tar.gz" -so | 7z x -aoa -si -ttar -o"predix-cli"
  REM Just put in the chocolatey/bin directory, since we know that's on the PATH env var.
  copy /Y predix-cli\bin\win64\predix.exe %ALLUSERSPROFILE%\chocolatey\bin\
  echo "mklink if not already there"
  mklink %ALLUSERSPROFILE%\chocolatey\bin\px.exe %ALLUSERSPROFILE%\chocolatey\bin\predix.exe
  echo mkdir C:\Progra~1\Git\etc\bash_completion.d\predix
  mkdir C:\Progra~1\Git\etc\bash_completion.d\predix
  echo copy /Y predix-cli\autocomplete\bash_autocomplete C:\Progra~1\Git\etc\bash_completion.d\predix\bash_autocomplete.sh
  copy /Y predix-cli\autocomplete\bash_autocomplete C:\Progra~1\Git\etc\bash_completion.d\predix\bash_autocomplete.sh
  echo add to %HOMEPATH%\.bashrc
  echo . /etc/bash_completion.d/predix/bash_autocomplete.sh >> %HOMEPATH%\.bashrc
  ECHO Predix CLI installed here: %ALLUSERSPROFILE%\chocolatey\bin\
) ELSE (
  ECHO check for upgrade
  predix -v >pxcliv.tmp
  SET /p predixcli_current_version=<pxcliv.tmp
  CALL :DOWNLOAD_TO_FILE https://api.github.com/repos/PredixDev/predix-cli/releases , predix-cli-release-response.tmp
  <predix-cli-release-response.tmp (jq -r ".[0].tag_name" >predix-cli-release-response-name.tmp)
  <predix-cli-release-response-name.tmp (SET /p cli_latest_tag=)
  SET cli_latest_tag=!cli_latest_tag:~1!
  echo.!predixcli_current_version!|findstr /C:!cli_latest_tag! >nul 2>&1
  if not errorlevel 1 (
    ECHO PREDIX CLI is current
  ) else (
    ECHO Upgrading Predix CLI to version  !cli_latest_tag!
    CALL :UPGRADE_PREDIXCLI
  )
  ECHO Predix CLI already installed, predix is installed at...
  where predix
  ECHO Predix CLI already installed, px shortcut is installed at...
  where px
  ECHO Predix CLI version is as follows, please check for updates at https://github.com/PredixDev/predix-cli
)
predix -v
GOTO :eof

:UPGRADE_PREDIXCLI
  ECHO Upgrading predixcli...
  ECHO Downloading installer
  CALL :CHOCO_INSTALL 7zip.commandline 7z
  REM get the url of the release file
  CALL :DOWNLOAD_TO_FILE https://api.github.com/repos/PredixDev/predix-cli/releases , predix-cli-output.tmp
  <predix-cli-output.tmp ( jq -r ".[0].assets[0].browser_download_url" >predix-cli-output2.tmp )
  SET /p cli_url=<predix-cli-output2.tmp
  CALL :DOWNLOAD_BINARY_TO_FILE !cli_url! , predix-cli.tar.gz
  7z x "predix-cli.tar.gz" -so | 7z x -aoa -si -ttar -o"predix-cli"
  REM Just put in the chocolatey/bin directory, since we know that's on the PATH env var.
  copy /Y predix-cli\bin\win64\predix.exe %ALLUSERSPROFILE%\chocolatey\bin\
  echo "mklink if not already there"
  mklink %ALLUSERSPROFILE%\chocolatey\bin\px.exe %ALLUSERSPROFILE%\chocolatey\bin\predix.exe
  mkdir C:\Progra~1\Git\etc\bash_completion.d\predix
  copy /Y predix-cli\autocomplete\bash_autocomplete C:\Progra~1\Git\etc\bash_completion.d\predix\bash_autocomplete.sh
  echo . /etc/bash_completion.d/predix/bash_autocomplete.sh >> %HOMEPATH%\.bashrc
  ECHO Predix CLI installed here: %ALLUSERSPROFILE%\chocolatey\bin\
GOTO :eof

:INSTALL_ANDROID_STUDIO
  ECHO.
  ECHO Installing Android Studio...
  CALL :CHOCO_INSTALL maven
  CALL :CHOCO_INSTALL ant
  CALL :CHOCO_INSTALL gradle

  CALL :CHOCO_INSTALL androidstudio -y
  CALL :CHOCO_INSTALL adb
  ECHO Installing Android Studio complete...
GOTO :eof

:INSTALL_MOBILECLI
ECHO.
ECHO Installing mobilecli...
where pm >$null 2>&1
IF NOT !errorlevel! EQU 0 (
  ECHO Downloading installer
  CALL :CHOCO_INSTALL 7zip.commandline 7z
  REM get the url of the release file
  CALL :DOWNLOAD_TO_FILE https://api.github.com/repos/PredixDev/predix-mobile-cli/releases , mobile-output.tmp
  <mobile-output.tmp ( jq -r "[ .[] | select(.prerelease==false) ] | .[0].assets[]  |  select(.name | contains(\"win\")) | .browser_download_url" >mobile-output2.tmp )
  <mobile-output2.tmp (SET /p cli_url=)
  CALL :DOWNLOAD_BINARY_TO_FILE !cli_url! , pm.zip
  del /Q /S mobile-cli
  7z x "pm.zip" -o"mobile-cli"
  REM Just put in the chocolatey/bin directory, since we know that's on the PATH env var.
  copy mobile-cli\pm.exe %ALLUSERSPROFILE%\chocolatey\bin\
  ECHO Mobile CLI installed here: %ALLUSERSPROFILE%\chocolatey\bin\
) ELSE (
  ECHO Mobile CLI already installed, pm is installed at...
  where pm
  ECHO Mobile CLI version is as follows, please check for updates at https://github.com/PredixDev/predix-mobile-cli
)
rem pm -v
GOTO :eof


:START
PUSHD "%~dp0"

ECHO --------------------------------------------------------------
ECHO This script will install tools required for Predix development
ECHO --------------------------------------------------------------

SET git=0
SET cf=1
SET putty=2
SET jdk=3
SET maven=4
SET sts=5
rem SET curl=6
SET nodejs=6
SET python2=7
SET python3=8
SET jq=9
SET predixcli=10
SET mobilecli=11
SET androidstudio=12

CALL :PROCESS_ARGS %*

CALL :CHECK_INTERNET_CONNECTION
CALL :GET_DEPENDENCIES
CALL :INSTALL_CHOCO

IF !install[jq]! EQU 1 CALL :CHOCO_INSTALL jq

IF !install[git]! EQU 1 CALL :CHOCO_INSTALL git

IF !install[cf]! EQU 1 (
  CALL :CHOCO_INSTALL cloudfoundry-cli cf
  CALL :RELOAD_ENV

  SETLOCAL
  IF EXIST "%ProgramFiles(x86)%" (
    SET filename=predix_win64.exe
  ) ELSE (
  SET filename=predix_win32.exe
  )
  ( cf plugins | findstr "Predix" >$null 2>&1 ) || cf install-plugin -f https://github.com/PredixDev/cf-predix/releases/download/1.0.0/!filename!
  ENDLOCAL

  IF NOT !errorlevel! EQU 0 (
    ECHO If you are behind a corporate proxy, set the 'http_proxy' and 'https_proxy' environment variables.
    ECHO Commands to set proxy:
    ECHO set http_proxy="http://<proxy-host>:<proxy-port>"
    ECHO set https_proxy="http://<proxy-host>:<proxy-port>"
    exit /b !errorlevel!
  )
)

IF !install[putty]! EQU 1 CALL :CHOCO_INSTALL putty
IF !install[jdk]! EQU 1 CALL :CHOCO_INSTALL jdk8 javac
IF !install[maven]! EQU 1 CALL :CHOCO_INSTALL maven mvn
REM TODO - Uncomment once the chocolatey package is fixed
REM IF !install[sts]! EQU 1 CALL :CHOCO_INSTALL springtoolsuite
rem IF !install[curl]! EQU 1 CALL :CHOCO_INSTALL curl

IF !install[nodejs]! EQU 1 (
  ECHO.
  ECHO Install Node.js
  CALL :CHOCO_INSTALL nodejs.install node
)
CALL :RELOAD_ENV
SET "PATH=%PATH%;%APPDATA%\npm"
IF !install[nodejs]! EQU 1 (
  ECHO "ensure npm global location (typically C:\Users\YourUserName\AppData\Roaming\npm) is in the path.  If not, please add manually in System and reopen this Admin Command window."
  path
  ECHO.
  ECHO 'If you get a certificate error, it could mean your company network and/or proxy server is using self signed certificates.  You can temporily use   npm config set strict-ssl false to allow the download or also try npm config set cafile="C:\mycacert.pem"'
  ECHO.
  where bower >$null 2>&1
  IF NOT !errorlevel! EQU 0 (
    ECHO npm install -g bower
    npm install -g bower
    CALL :CHECK_FAIL
  )
  where grunt >$null 2>&1
  IF NOT !errorlevel! EQU 0 (
    ECHO npm install -g grunt
    npm install -g grunt-cli
    CALL :CHECK_FAIL
  )
  where gulp >$null 2>&1
  IF NOT !errorlevel! EQU 0 (
    ECHO npm install -g gulp
    path
    npm install -g gulp-cli
    CALL :CHECK_FAIL
  )
  where node-gyp >$null 2>&1
  IF NOT !errorlevel! EQU 0 (
    ECHO npm install -g node-gyp
    path
    npm install -g node-gyp
    CALL :CHECK_FAIL    
    ECHO npm install -g --production windows-build-tools
    npm install --g --production windows-build-tools
    CALL :CHECK_FAIL
  )
)

IF !install[python2]! EQU 1 (
  ECHO.
  ECHO install python2
  CALL :CHOCO_INSTALL python2 python
)
IF !install[python3]! EQU 1 ( 
  ECHO.
  ECHO install python3
  CALL :CHOCO_INSTALL python3 python3
)

IF !install[predixcli]! EQU 1 (
  CALL :INSTALL_PREDIXCLI
)
IF !install[mobilecli]! EQU 1 (
  CALL :INSTALL_MOBILECLI
)

IF !install[androidstudio]! EQU 1 (
  CALL :INSTALL_ANDROID_STUDIO
)

POPD
ECHO.
ECHO Installation of tools completed. If your script has completed, close this administrator command window and open a new non-administrator prompt and proceed.
ECHO If you installed git, we recommend using a regular Windows command window to login to the Predix Cloud and a git-bash window found in the start menu for everything else.
ECHO If running a tutorial script, press any key to continue.  Be sure to work out of a git-bash window for your everyday work.

EXIT /b 0
