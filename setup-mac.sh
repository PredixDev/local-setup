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
  curl "http://google.com" > /dev/null 2>&1
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

function install_brew_cask() {
  # Install brew and cask
  if which brew > /dev/null; then
    echo "brew already installed, tapping cask, this may take a full minute"
  else
    echo "Installing brew and cask, this may take a few minutes"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew tap caskroom/cask
}

function brew_install() {
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
    brew install $TOOL
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
}

function install_git() {
  brew_install git
  git --version
}

function install_cf() {
  brew tap cloudfoundry/tap
  brew_install cf-cli cf
  cf -v

  # Install CF Predix plugin
  set +e
  cf plugins | grep Predix > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    set -e
    cf install-plugin -f https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_osx
  fi
  set -e
}

function install_jdk() {
  brew_cask_install java
  javac -version
}

function install_maven() {
  brew_install maven mvn
  mvn -v
}

function install_nodejs() {
  brew_install node
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
  brew_install python3
  python3 --version
}

function install_python2() {
  brew_install python2
  python2 --version

}

function install_jq() {
  brew_install jq
  jq --version
}

function install_uaac() {
  # Install tools for managing ruby
  brew_install rbenv
  brew_install ruby-build
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
    echo "Please enter your system password, so the Predix CLI can be installed using sudo."
    sudo ./predix-cli/install
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
    echo "Please enter your system password, so the Predix CLI can be installed using sudo."
    sudo ./predix-cli/install
  fi

}

function install_mobilecli() {
  if which pm > /dev/null; then
    echo "Predix Mobile CLI already installed."
    pm
  else
    #cli_url=$(curl -g -s -L https://api.github.com/repos/PredixDev/predix-mobile-cli/releases | jq -r '.' )
    cli_url=$(curl -g -s -L https://api.github.com/repos/PredixDev/predix-mobile-cli/releases | jq -r '[ .[] | select(.prerelease==false) ] | .[0].assets[]  |  select(.name | contains("Mac")) | .browser_download_url' )
    cli_install_url="https://raw.githubusercontent.com/PredixDev/local-setup/mobile-cli-install.sh"
    #cli_install_url="https://github.build.ge.com/raw/adoption/local-setup/develop/mobile-cli-install.sh"
    echo "Downloading latest Predix Mobile CLI: $cli_url"
    curl -L "$cli_url" -o pm.zip
    mkdir -p mobile-cli && tar -xf pm.zip -C mobile-cli
    cd mobile-cli
    curl -L -O "$cli_install_url"
    chmod +x mobile-cli-install
    echo "Please enter your system password, so the Predix Mobile CLI can be installed using sudo."
    sudo ./mobile-cli-install
  fi
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
      shift
    done
    install[jq]=1
  fi

  check_internet
  check_bash_profile
  install_brew_cask

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
    brew_cask_install sts
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
}

run_setup $@
