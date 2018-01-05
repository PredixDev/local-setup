# Local setup of development tools

Scripts to install the tools required for development on the Predix Platform.

## Installation

### On Mac OS X

* Run the command below in a terminal window to install all the standard tools
```
bash <( curl https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-mac.sh )
```
* You can choose to install selected tools by providing flags for the corresponding tools.
For example: to install git and cf-cli only run
```
bash <( curl https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-mac.sh ) --git --cf
```

Tool | Flag | Notes
--- | --- | ---
[brew](http://brew.sh), [cask] (http://caskroom.io) | | Required to manage the installation of tools
[Git](https://git-scm.com) | --git |
[Cloud Foundry CLI](http://docs.cloudfoundry.org/cf-cli) | --cf |
[Java SE Development Kit (JDK)](http://www.oracle.com/technetwork/java/javase/downloads/index.html) | --jdk |
[Maven](https://maven.apache.org) | --maven |
[Eclipse STS](https://spring.io/tools/sts) | --sts |
[Node.js](https://nodejs.org), [Bower](http://bower.io/), [Grunt CLI](http://gruntjs.com), [Gulp CLI](http://gulpjs.com) | --nodejs |
[Predix CLI](https://github.com/PredixDev/predix-cli) | --predixcli |
[Predix Mobile CLI](https://github.com/PredixDev/predix-mobile-cli) | --mobilecli |
[Python2](https://www.python.org) | --python2 |
[Python3](https://www.python.org) | --python3 |
[rbenv](http://rbenv.org), [ruby-build](https://github.com/rbenv/ruby-build), [ruby](https://www.ruby-lang.org), [cf-uaac] (https://github.com/cloudfoundry/cf-uaac) | --uaac | This is not installed by default

### On Windows
* Open a Command Window as Administrator (Right click 'Run as Administrator') and run the command below
```
@powershell -Command "(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-windows.bat','%TEMP%/setup-windows.bat')" && "%TEMP%/setup-windows.bat"
```
* You can choose to install selected tools by providing flags for the corresponding tools.
For example: to install git and cf-cli only run
```
@powershell -Command "(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-windows.bat','%TEMP%/setup-windows.bat')" && %TEMP%/setup-windows.bat /git /cf
```

Tool | Flag | Notes
--- | --- | ---
[chocolatey](https://chocolatey.org) | | Required to manage the installation of tools
[Git](https://git-scm.com) | /git |
[Cloud Foundry CLI](http://docs.cloudfoundry.org/cf-cli) | /cf |
[putty](http://www.putty.org) | /putty |
[Java SE Development Kit (JDK)](http://www.oracle.com/technetwork/java/javase/downloads/index.html) | /jdk |
[Maven](https://maven.apache.org) | /maven |
[Eclipse STS](https://spring.io/tools/sts) | /sts |
[cURL](https://curl.haxx.se) | /curl |
[Node.js](https://nodejs.org), [Bower](http://bower.io/), [Grunt CLI](http://gruntjs.com), [Gulp CLI](http://gulpjs.com) | /nodejs |
[Predix CLI](https://github.com/PredixDev/predix-cli) | /predixcli |
[Predix Mobile CLI](https://github.com/PredixDev/predix-mobile-cli) | /mobilecli |
[Python2](https://www.python.org) | /python2 |
[Python3](https://www.python.org) | /python3 |

[![Analytics](https://ga-beacon.appspot.com/UA-82773213-1/local-setup/readme?pixel)](https://github.com/PredixDev)
