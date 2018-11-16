# Local setup of development tools

Scripts to install the tools required for development on the Predix Platform.

## Installation

### On Mac OS X

* Run the command below in a terminal window to install all the standard tools
```
bash <( curl https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-mac.sh )
```
* You can choose to install selected tools by providing flags for the corresponding tools.
For example: to install git, cf-cli, and predix-cli only run
```
bash <( curl https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-mac.sh ) --git --cf --predixcli
```

Tool | Flag | Notes
--- | --- | ---
[brew](http://brew.sh), [cask] (http://caskroom.io) | | Required to manage the installation of tools
[Android Studio & Platform Tools](https://developer.android.com/studio/index.html) | --androidstudio |
[Cloud Foundry CLI](http://docs.cloudfoundry.org/cf-cli) | --cf |
[Docker](https://docs.docker.com/docker-for-mac/install/) | --docker |
[Eclipse STS](https://spring.io/tools/sts) | --sts |
[Git](https://git-scm.com) | --git |
[Java SE Development Kit (JDK)](http://www.oracle.com/technetwork/java/javase/downloads/index.html) | --jdk |
[JQ)](https://stedolan.github.io/jq/) | installed in all cases |
[Maven](https://maven.apache.org) | --maven |
[Node.js](https://nodejs.org), [Bower](http://bower.io/), [Grunt CLI](http://gruntjs.com), [Gulp CLI](http://gulpjs.com),[node gyp]https://github.com/nodejs/node-gyp,[windows-build-tools] (npm install --global --production windows-build-tools)  | --nodejs |
[Predix CLI](https://github.com/PredixDev/predix-cli) | --predixcli |
[Predix Mobile CLI](https://github.com/PredixDev/predix-mobile-cli) | --mobilecli |
[Python2](https://www.python.org) | --python2 |
[Python3](https://www.python.org) | --python3 |
[rbenv](http://rbenv.org), [ruby-build](https://github.com/rbenv/ruby-build), [ruby](https://www.ruby-lang.org), [cf-uaac] (https://github.com/cloudfoundry/cf-uaac) | --uaac | This is not installed by default
[VMWare](https://www.vmware.com/products/fusion/fusion-evaluation.html) | --vmware | 

### On Windows
* Open a Command Window as Administrator (Right click 'Run as Administrator') and run the command below
```
@powershell -Command "(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-windows.bat','%TEMP%/setup-windows.bat')" && %TEMP%/setup-windows.bat
```
* You can choose to install selected tools by providing flags for the corresponding tools.
For example: to install git, cf-cli and predix-cli only run
```
@powershell -Command "(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/PredixDev/local-setup/master/setup-windows.bat','%TEMP%/setup-windows.bat')" && %TEMP%/setup-windows.bat /git /cf /predixcli
```

Tool | Flag | Notes
--- | --- | ---
[chocolatey](https://chocolatey.org) | | Required to manage the installation of tools
[Android Studio & ADB](https://developer.android.com/studio/index.html) | /androidstudio |
[Cloud Foundry CLI](http://docs.cloudfoundry.org/cf-cli) | /cf |
[cURL](https://curl.haxx.se) | /curl |
[Docker](https://docs.docker.com/docker-for-windows/install/) | /docker |
[Eclipse STS](https://spring.io/tools/sts) | /sts |
[Git](https://git-scm.com) | /git |
[Java SE Development Kit (JDK)](http://www.oracle.com/technetwork/java/javase/downloads/index.html) | /jdk |
[JQ)](https://stedolan.github.io/jq/) | installed in all cases |
[Maven](https://maven.apache.org) | /maven |
[Node.js](https://nodejs.org), [Bower](http://bower.io/), [Grunt CLI](http://gruntjs.com), [Gulp CLI](http://gulpjs.com) | /nodejs |
[Predix CLI](https://github.com/PredixDev/predix-cli) | /predixcli |
[Predix Mobile CLI](https://github.com/PredixDev/predix-mobile-cli) | /mobilecli |
[Python2](https://www.python.org) | /python2 |
[Python3](https://www.python.org) | /python3 |
[putty](http://www.putty.org) | /putty |
[VMWare](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html) | /vmware |

[![Analytics](https://predix-beacon.appspot.com/UA-82773213-1/local-setup/readme?pixel)](https://github.com/PredixDev)
