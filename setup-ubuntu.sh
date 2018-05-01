#!/bin/bash
set -e

git=0
cf=1
jdk=2
maven=3
sts=4
nodejs=5
python2=6
python3=7
uaac=8
jq=9
predixcli=10
mobilecli=11
androidstudio=12

declare -a install

function prefix_to_path() {
  if [[ ":$PATH:" != *":$1:"* ]]; then
    echo 'export PATH="$1${PATH:+":$PATH"}"' >> ~/.bash_profile
    source ~/.bash_profile
  fi
}

function check_internet() {
  set +e
  echo ""
  echo "Checking internet connection..."
  curl "http://github.com" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy.  Please read this tutorial for detailed info about setting your proxy https://www.predix.io/resources/tutorials/tutorial-details.html?tutorial_id=1565"
    exit 1
  fi
  echo "OK"
  echo ""
  set -e
}

function check_bash_profile() {
  # Ensure bash profile exists
  if [ ! -e ~/.bash_profile ]; then
    printf "#!/bin/bash\n" >> ~/.bash_profile
  fi

  # This is required for brew to work
  prefix_to_path /usr/local/bin
}

function install_apt_get() {
  # Install brew and cask
  if which apt-get > /dev/null; then
    echo "apt-get already installed, this may take a full minute"
  else
    echo "Installing apt-get"
    wget http://security.ubuntu.com/ubuntu/pool/main/a/apt/apt_1.0.1ubuntu2.17_amd64.deb -O apt.deb
    dpkg -i apt.deb
  fi
  apt-get --yes update
  if which unzip > /dev/null; then
    echo "unzip already installed"
  else
    echo "Installing apt-get"
    apt-get install unzip
  fi
}

function apt_get_install() {
  echo "--------------------------------------------------------------"
  TOOL=$1
  COMMAND=$1
  if [ $# -eq 2 ]; then
    COMMAND=$2
  fi

  if which $COMMAND > /dev/null; then
    echo "$TOOL already installed"
  else
    echo "Installing $TOOL"
    apt-get --yes update
    apt-get --yes install $TOOL
  fi
}

function brew_cask_install() {
  echo "--------------------------------------------------------------"
  TOOL=$1

  if brew cask list | grep $TOOL > /dev/null; then
    echo "$TOOL already installed"
  else
    echo "Installing $TOOL"
    brew cask install $TOOL
  fi
}

function install_everything() {
  install[git]=1
  install[cf]=1
  install[jdk]=1
  install[maven]=1
  install[sts]=1
  install[nodejs]=1
  install[python2]=1
  install[python3]=1
  install[uaac]=0 # Install UAAC only if the --uaac flag is provided
  install[jq]=1
  install[predixcli]=1
  install[mobilecli]=1
  install[androidstudio]=0 # Install Android Studio only if --androidstudio flag is provided
}

function install_nothing() {
  install[git]=0
  install[cf]=0
  install[jdk]=0
  install[maven]=0
  install[sts]=0
  install[nodejs]=0
  install[python2]=0
  install[python3]=0
  install[uaac]=0
  install[jq]=0
  install[predixcli]=0
  install[mobilecli]=0
  install[androidstudio]=0
}

function install_git() {
  apt_get_install git
  git --version
}

function install_cf() {
  #wget --no-check-certificate -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
  #echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
  # ...then, update your local package index, then finally install the cf CLI
  if which cf > /dev/null; then
    echo "cf cli already installed"
  else
    rm -rf cf-cli-installer_6.36.1_x86-64.*
    wget --no-check-certificate https://s3-us-west-1.amazonaws.com/cf-cli-releases/releases/v6.36.1/cf-cli-installer_6.36.1_x86-64.deb
    dpkg -i cf-cli-installer_6.36.1_x86-64.deb && apt-get --yes install -f
    rm -rf cf-cli-installer_6.36.1_x86-64.*
  fi
  cf -v

  # Install CF Predix plugin
  set +e
  cf plugins | grep Predix > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    set -e
    cf install-plugin -f https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_linux64
  fi
  set -e
}

function install_jdk() {
  apt_get_install openjdk-8-jdk
  javac -version
}

function install_maven() {
  apt_get_install maven
  mvn -v
}

function install_android_studio() {
  echo "--------------------------------------------------------------"
  echo "Android Studio will require Maven, Ant, and Gradle"

  # Install tools used by Android Studio
  install_maven
  apt_get_install ant
  apt_get_install gradle

  # Install Android Studio dependencies
  apt-get --yes install software-properties-common
  apt-add-repository ppa:android-studio
  apt_get_install android-studio
  apt_get_install android-platform-tools
}

function install_nodejs() {
  apt_get_install nodejs
  apt_get_install npm
  node -v
  echo -ne "\nnpm "
  npm -v

  type bower > /dev/null || npm install -g bower
  echo -ne "\nbower "
  bower -v

  type grunt > /dev/null || npm install -g grunt-cli
  grunt --version

  type gulp > /dev/null || npm install -g gulp-cli
  echo -ne "\ngulp "
  gulp --version
  echo "node install complete"
}

function install_python3() {
  apt_get_install python3
  python3 --version
}

function install_python2() {
  apt_get_install python
  python2 --version

}

function install_jq() {
  apt_get_install jq
  jq --version
}

function install_uaac() {
  # Install tools for managing ruby
  apt_get_install rbenv
  apt_get_install ruby-build
  # Add rbenv to bash
  grep -q -F 'rbenv init' ~/.bash_profile || echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile && eval "$(rbenv init -)"
  # Install latest ruby
  RUBY_VERSION=`egrep "^\s+\d+\.\d+\.\d+$" <(rbenv install -l) | tail -1 | tr -d '[[:space:]]'`
  echo "--------------------------------------------------------------"
  if grep -q "$RUBY_VERSION" <(ruby -v); then
    echo "Already running latest version of ruby"
  else
    echo "Installing latest ruby"
    rbenv install $RUBY_VERSION
    rbenv global $RUBY_VERSION
  fi
  ruby -v

  # Install UAAC
  echo "--------------------------------------------------------------"
  echo "Installing UAAC gem"
  gem install cf-uaac
}

function install_predixcli() {
  if which predix > /dev/null; then
    echo "Predix CLI already installed."
    predix -v
    PREDIX_VERSION=$(predix -v | awk -F" " '{print $3}')
    update_predixcli $PREDIX_VERSION
  else
    cli_url=$(curl -s -L https://api.github.com/repos/PredixDev/predix-cli/releases | jq -r ".[0].assets[0].browser_download_url")
    echo "Downloading latest Predix CLI: $cli_url"
    curl -L -O "$cli_url"
    mkdir -p predix-cli && tar -xf predix-cli.tar.gz -C predix-cli
    if [ -e predix-cli ]; then
      #tar -C is supposed to change directory but it doesn't sometimes
      cd predix-cli
    fi
    ./install
  fi
}


function update_predixcli() {
  #echo "Predix CLI updgrade"$1
  existing_version=$1
  cli_version_name=$(curl -s -L https://api.github.com/repos/PredixDev/predix-cli/releases | jq -r ".[0].tag_name")
  cli_version_name=${cli_version_name:1}
  echo "Predix CLI already installed version."$existing_version
  echo "Predix CLI new installed version."$cli_version_name
  echo "checking for upgrade"
  if [[ "$existing_version" != *"$cli_version_name"* ]]; then
    echo "Upgrading Predix CLI to version" $cli_version_name
    cli_url=$(curl -s -L https://api.github.com/repos/PredixDev/predix-cli/releases | jq -r ".[0].assets[0].browser_download_url")
    echo "Downloading latest Predix CLI: $cli_url"
    curl -L -O "$cli_url"
    mkdir -p predix-cli && tar -xf predix-cli.tar.gz -C predix-cli
    if [ -e predix-cli ]; then
      #tar -C is supposed to change directory but it doesn't sometimes
      cd predix-cli
    fi
    ./install
  fi

}

function install_mobilecli() {
  if which pm > /dev/null; then
    echo "Predix Mobile CLI already installed."
    pm version
  else
    #cli_url=$(curl -g -s -L https://api.github.com/repos/PredixDev/predix-mobile-cli/releases | jq -r '.' )
    cli_url=$(curl -g -s -L https://api.github.com/repos/PredixDev/predix-mobile-cli/releases | jq -r '[ .[]]  | .[0].assets[] | select(.name | contains("linux-x64"))| .browser_download_url' )
    cli_install_url="https://raw.githubusercontent.com/PredixDev/local-setup/master/mobile-cli-install"
    cli_install_root_url="https://raw.githubusercontent.com/PredixDev/local-setup/master/mobile-cli-root-install"
    #cli_install_url="https://raw.githubusercontent.com/PredixDev/local-setup/develop/mobile-cli-install.sh"
    echo "Downloading latest Predix Mobile CLI: $cli_url"
    curl -L "$cli_url" -o pm.zip
    mkdir -p mobile-cli && unzip pm.zip -d mobile-cli
    cd mobile-cli
    echo $cli_install_url
    curl -L -O "$cli_install_url"
    echo $cli_install_root_url
    curl -L -O "$cli_install_root_url"
    chmod +x mobile-cli-install
    chmod +x mobile-cli-root-install
    ./mobile-cli-install
  fi
}

function install_sts() {
  rm -rf spring-tool-suite-3.9.4.RELEASE-e4.7.3a-linux-gtk-x86_64.*
  rm -rf sts-bundle
  wget --no-check-certificate http://download.springsource.com/release/STS/3.9.4.RELEASE/dist/e4.7/spring-tool-suite-3.9.4.RELEASE-e4.7.3a-linux-gtk-x86_64.tar.gz
  tar xf spring-tool-suite-3.9.4.RELEASE-e4.7.3a-linux-gtk-x86_64.tar.gz
  rm -rf spring-tool-suite-3.9.4.RELEASE-e4.7.3a-linux-gtk-x86_64.tar.gz
}

function run_setup() {
  echo "--------------------------------------------------------------"
  echo "This script will install tools required for Predix development"
  echo "You may be asked to provide your password during the installation process"
  echo "--------------------------------------------------------------"
  echo ""
  if [ -z "$1" ]; then
    echo "Installing all the tools..."
    install_everything
  else
    echo "Installing only tools specified in parameters..."
    install_nothing
    while [ ! -z "$1" ]; do
      [ "$1" == "--git" ] && install[git]=1
      [ "$1" == "--cf" ] && install[cf]=1
      [ "$1" == "--jdk" ] && install[jdk]=1
      [ "$1" == "--maven" ] && install[maven]=1
      [ "$1" == "--sts" ] && install[sts]=1
      [ "$1" == "--nodejs" ] && install[nodejs]=1
      [ "$1" == "--python2" ] && install[python2]=1
      [ "$1" == "--python3" ] && install[python3]=1
      [ "$1" == "--uaac" ] && install[uaac]=1
      [ "$1" == "--jq" ] && install[jq]=1
      [ "$1" == "--predixcli" ] && install[predixcli]=1
      [ "$1" == "--mobilecli" ] && install[mobilecli]=1
      [ "$1" == "--androidstudio" ] && install[androidstudio]=1
      shift
    done
    install[jq]=1
  fi

  check_internet
  check_bash_profile
  install_apt_get

  if [ ${install[jq]} -eq 1 ]; then
    install_jq
  fi

  if [ ${install[git]} -eq 1 ]; then
    install_git
  fi

  if [ ${install[cf]} -eq 1 ]; then
    install_cf
  fi

  if [ ${install[jdk]} -eq 1 ]; then
    install_jdk
  fi

  if [ ${install[maven]} -eq 1 ]; then
    install_maven
  fi

  if [ ${install[sts]} -eq 1 ]; then
    install_sts
  fi

  if [ ${install[nodejs]} -eq 1 ]; then
    install_nodejs
  fi

  if [ ${install[python3]} -eq 1 ]; then
    install_python3
  fi
  if [ ${install[python2]} -eq 1 ]; then
    install_python2
  fi

  if [ ${install[uaac]} -eq 1 ]; then
    install_uaac
  fi

  if [ ${install[predixcli]} -eq 1 ]; then
    install_predixcli
  fi

  if [ ${install[mobilecli]} -eq 1 ]; then
    install_mobilecli
  fi

  if [ ${install[androidstudio]} -eq 1 ]; then
    install_android_studio
  fi
}

run_setup $@
