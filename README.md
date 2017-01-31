# Local setup of development tools

Scripts to install the tools required for development on the Predix Platform.

## Installation

### On Mac OS X (Frontend Tools Javascript development)

* Run the command below in a terminal window to install all the standard tools for frontend development (Includes latest Ruby, Brew, Git, Cloud Foundry, Predix User Access Control, NodeJS - Bower & Grunt, Redis, Polymer Web Component Tester, Java JDK)
```
bash <( curl https://raw.githubusercontent.com/predix-edgemanager-ui/local-setup/master/setup-mac-fe.sh )
```
* You can choose to install selected tools by providing flags for the corresponding tools.
For example: to install git and cf-cli only run
```
bash <( curl https://raw.githubusercontent.com/predix-edgemanager-ui/local-setup/master/setup-mac-fe.sh ) --git --cf
```

Tool | Flag | Notes
--- | --- | ---
[brew] (http://brew.sh), [cask] (http://caskroom.io) | | Required to manage the installation of tools
[Git] (https://git-scm.com) | --git | Git Repository
[Cloud Foundry cli] (http://docs.cloudfoundry.org/cf-cli) | --cf | Used for Predix
[cf-uaac] (https://github.com/cloudfoundry/cf-uaac) | --uaac | (Frontend) User Access Control for Predix 
[Node.js] (https://nodejs.org), [Bower] (http://bower.io/), [Grunt CLI] (http://gruntjs.com) | --nodejs | (Frontend) UI Tools
[Redis] (https://redis.io/) | --redis | Datastore
[Polymer Web Component Tester] (https://github.com/Polymer/web-component-tester) | --wct | (Frontend) UI testing tool
[Java SE Development Kit (JDK)] (http://www.oracle.com/technetwork/java/javase/downloads/index.html) | --jdk | Language Used for Frontend Testing
[rbenv] (http://rbenv.org), [ruby-build] (https://github.com/rbenv/ruby-build), [ruby] (https://www.ruby-lang.org) | | 


### On Mac OS X (Backend Tools Java development)

* Run the command below in a terminal window to install all the standard backend development tools (Includes latest Ruby, Brew, Git, Cloud Foundry, Predix User Access Control, Java JDK, Maven, Eclipse STS, Python3)
```
bash <( curl https://raw.githubusercontent.com/predix-edgemanager-ui/local-setup/master/setup-mac-be.sh )
```
* You can choose to install selected tools by providing flags for the corresponding tools.
For example: to install git and cf-cli only run
```
bash <( curl https://raw.githubusercontent.com/predix-edgemanager-ui/local-setup/master/setup-mac-be.sh ) --git --cf
```

Tool | Flag | Notes
--- | --- | ---
[brew] (http://brew.sh), [cask] (http://caskroom.io) | | Required to manage the installation of tools
[Git] (https://git-scm.com) | --git | Git Repository
[Cloud Foundry cli] (http://docs.cloudfoundry.org/cf-cli) | --cf | Used for Predix
[cf-uaac] (https://github.com/cloudfoundry/cf-uaac) | --uaac | User Access Control for Predix 
[Java SE Development Kit (JDK)] (http://www.oracle.com/technetwork/java/javase/downloads/index.html) | --jdk | Language
[Eclipse STS] (https://spring.io/tools/sts) | --sts | Spring IDE
[Maven] (https://maven.apache.org) | --maven | Software Build Management
[Python3] (https://www.python.org) | --python3 | Language
[rbenv] (http://rbenv.org), [ruby-build] (https://github.com/rbenv/ruby-build), [ruby] (https://www.ruby-lang.org) | | 


### On Windows
* Open a Command Window as Administrator (Right click 'Run as Administrator') and run the command below
```
@powershell -Command "(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/predix-edgemanager-ui/local-setup/master/setup-windows.bat','%TEMP%\setup-windows.bat')" && "%TEMP%\setup-windows.bat"
```
* You can choose to install selected tools by providing flags for the corresponding tools.
For example: to install git and cf-cli only run
```
@powershell -Command "(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/predix-edgemanager-ui/local-setup/master/setup-windows.bat','%TEMP%\setup-windows.bat')" && "%TEMP%\setup-windows.bat /git /cf"
```

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
[Node.js] (https://nodejs.org), [Bower] (http://bower.io/), [Grunt CLI] (http://gruntjs.com) | /nodejs |
[Python2] (https://www.python.org) | /python2 |
[Python3] (https://www.python.org) | /python3 |

[![Analytics](https://ga-beacon.appspot.com/UA-82773213-1/local-setup/readme?pixel)](https://github.com/PredixDev)

