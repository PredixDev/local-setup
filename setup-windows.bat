@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

REM Reload environment variables to make sure the script can find choco
resetvars.vbs
call "%TEMP%\resetvars.bat"

choco install -y cloudfoundry-cli
choco install -y git
choco install -y jdk
choco install -y maven
choco install -y nodejs.install
choco install -y curl
choco install -y python2
choco install -y springtoolsuite

REM Reload environment variables to make sure the script can find cf & npm
resetvars.vbs
call "%TEMP%\resetvars.bat"

cf install-plugin https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_win64.exe

npm install -g bower
npm install -g grunt-cli
