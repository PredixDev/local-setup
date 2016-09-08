# Local setup of development tools

Scripts to install the tools required for development on the Predix Platform.

## Download the scripts

* Download the scripts from https://github.com/PredixDev/local-setup/archive/master.zip

* Extract the zip on your computer

## Installation

### On Mac OS X

* Open Terminal
* Navigate to the extracted folder `$ cd <path to folder>`
* Run `$ ./setup-mac.sh` to install all the standard tools
* You can choose to install selected tools by providing flag for the corresponding tool. For example: to install git and cf-cli only run `./setup-mac.sh --git --cf`

Tool | Flag | Notes
--- | --- | ---
[brew] (http://brew.sh), [cask] (http://caskroom.io) | | Required to manage the installation of tools
[Git] (https://git-scm.com) | --git |
[cf-cli] (http://docs.cloudfoundry.org/cf-cli) | --cf |
[Java SE Development Kit (JDK)] (http://www.oracle.com/technetwork/java/javase/downloads/index.html) | --jdk |
[Maven] (https://maven.apache.org) | --maven |
[Eclipse STS] (https://spring.io/tools/sts) | --sts |
[Node.js] (https://nodejs.org), [Bower] (http://bower.io/), [Grunt CLI] (http://gruntjs.com) | --nodejs |
[rbenv] (http://rbenv.org), [ruby-build] (https://github.com/rbenv/ruby-build), [ruby] (https://www.ruby-lang.org), [cf-uaac] (https://github.com/cloudfoundry/cf-uaac) | --uaac | This is not installed by default

### On Windows
* Open Command Prompt as Administrator (Right click 'Run as Administrator')
* Navigate to the extracted folder `> cd [path to folder]`
* Run `> setup-windows.bat` to install all the standard tools
* You can choose to install selected tools by providing flag for the corresponding tool. For example: to install git and cf-cli only run `setup-windows.bat /git /cf`

Tool | Flag | Notes
--- | --- | ---
[chocolatey] (https://chocolatey.org) | | Required to manage the installation of tools
[Git] (https://git-scm.com) | /git |
[cf-cli] (http://docs.cloudfoundry.org/cf-cli) | /cf |
[putty] (http://www.putty.org) | /putty |
[Java SE Development Kit (JDK)] (http://www.oracle.com/technetwork/java/javase/downloads/index.html) | /jdk |
[Maven] (https://maven.apache.org) | /maven |
[Eclipse STS] (https://spring.io/tools/sts) | /sts |
[cURL] (https://curl.haxx.se) | /curl |
[Python2] (https://www.python.org) | /python2 |
[Node.js] (https://nodejs.org), [Bower] (http://bower.io/), [Grunt CLI] (http://gruntjs.com) | /nodejs |

[![Analytics](https://ga-beacon.appspot.com/UA-82773213-1/local-setup/readme?pixel)](https://github.com/PredixDev)
