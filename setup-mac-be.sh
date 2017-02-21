#!/bin/bash
set -e

git=0
cf=1
jdk=2
maven=3
sts=4
nodejs=5
python3=6
uaac=7
redis=8
wct=9

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
    echo "Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy"
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
    echo "brew already installed, tapping cask"
  else
    echo "Installing brew and cask"
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
  # For front end environment Maven, Spring STS and Python are not required
  install[git]=1
  install[cf]=1
  install[jdk]=1
  install[maven]=1
  install[sts]=1
  install[nodejs]=0
  install[python3]=1
  install[uaac]=1 # Install UAAC only if the --uaac flag is provided
  install[redis]=0
  install[wct]=0
}

function install_nothing() {
  install[git]=0
  install[cf]=0
  install[jdk]=0
  install[maven]=0
  install[sts]=0
  install[nodejs]=0
  install[python3]=0
  install[uaac]=0
  install[redis]=0
  install[wct]=0
}

function install_git() {
  echo "--------------------------------------------------------------"
  echo "Installing Git..."
  brew_install git
  git --version
}

function install_cf() {
  echo "--------------------------------------------------------------"
  echo "Installing Cloud Foundry..."
  brew tap cloudfoundry/tap
  brew_install cf-cli cf
  cf -v

  # Install CF Predix plugin
  echo "--------------------------------------------------------------"
  echo "Installing Predix plugin..."
  set +e
  cf plugins | grep Predix > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    set -e
    cf install-plugin -f https://github.com/PredixDev/cf-predix/releases/download/1.0.0/predix_osx
  fi
  set -e
}

function install_jdk() {
  echo "--------------------------------------------------------------"
  echo "Installing Java Development Kit..."
  brew_cask_install java
  javac -version
}

function install_maven() {
  echo "--------------------------------------------------------------"
  echo "Checking for brew update..."
  brew update
  echo "Installing Maven"
  brew_install maven
  mvn -version
}

function install_nodejs() {
  echo "--------------------------------------------------------------"
  echo "Installing NodeJs..."
  # brew_install node
  # Normally the command above would be fine, unfortunately the current environment requires node 5.11.1 and brew installs, by default, the latest stable version. 
  # We still install with brew but we also install a node verison manager 'n' to activate version 5.11.1.
  brew_install node
  echo "Installing NPM..."
  brew_install npm
  npm -v
  echo "Installing Node Manager..."
  npm install -g n
  echo "Setting Node to v5.11.1..."
  n 5.11.1
  node -v

  echo "--------------------------------------------------------------"
  echo "Setting NPM environment variables..."
  npm set prefix '/usr/local'
  npm set registry 'http://registry.npmjs.org'
  npm set strict-ssl false

  echo "--------------------------------------------------------------"
  echo "Installing Bower..."
  type bower > /dev/null || npm install -g bower
  echo -ne "\nbower "
  bower -v

  echo "--------------------------------------------------------------"
  echo "Installing Grunt Cli..."
  type grunt > /dev/null || npm install -g grunt-cli
  grunt --version
}

function install_redis() {
  # Install Redis
  echo "--------------------------------------------------------------"
  echo "Installing Redis"
  # brew_install redis
  # Normally the command above would be fine, however because the current environment requires redis 3.0.7 and brew does not have a proper formulae for that version. 
  # We revert to manually scripting the installation below.
  cd ~
  curl -O http://download.redis.io/releases/redis-3.0.7.tar.gz
  tar -xvzf redis-3.0.7.tar.gz
  rm redis-3.0.7.tar.gz
  cd redis-3.0.7
  make
  sudo make install
  redis-server --version
}

function install_wct() {
  # Install the Polymer web-components-tester
  echo "--------------------------------------------------------------"
  echo "Installing Polymer web component tester..."
  grantnpm
  npm install -g https://github.com/Polymer/web-component-tester.git#v4.2.2
  npm install web-component-tester-istanbul -g
}

function install_python3() {
  echo "--------------------------------------------------------------"
  echo "Installing Python 3..."
  brew_install python3
  python3 --version
}

function install_uaac() {
  # check for proper ruby environment
  check_rbenv
  # Install UAAC
  echo "--------------------------------------------------------------"
  echo "Installing UAAC with gem..."
  gem install cf-uaac
}

function check_rbenv() {
  # Install tools for managing ruby
  echo "--------------------------------------------------------------"
  # check for proper ruby environment
  echo "Checking for latest Ruby..."
  brew_install rbenv
  brew_install ruby-build
  # Add rbenv to bash
  grep -q -F 'rbenv init' ~/.bash_profile || echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile && eval "$(rbenv init -)"
  # Install latest ruby
  RUBY_VERSION=`egrep "^\s+\d+\.\d+\.\d+$" <(rbenv install -l) | tail -1 | tr -d '[[:space:]]'`
  if grep -q "$RUBY_VERSION" <(ruby -v); then
    echo "Already running latest version of ruby"
  else
    echo "Installing latest version of Ruby"
    rbenv install $RUBY_VERSION
    rbenv global $RUBY_VERSION
  fi
  ruby -v
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
      [ "$1" == "--python3" ] && install[python3]=1
      [ "$1" == "--uaac" ] && install[uaac]=1
      [ "$1" == "--redis" ] && install[redis]=1
      [ "$1" == "--wct" ] && install[wct]=1
      shift
    done
  fi

  check_internet
  check_bash_profile
  install_brew_cask
  check_rbenv

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

  if [ ${install[redis]} -eq 1 ]; then
    install_redis
  fi

  if [ ${install[wct]} -eq 1 ]; then
    install_wct
  fi

  if [ ${install[python3]} -eq 1 ]; then
    install_python3
  fi

  if [ ${install[uaac]} -eq 1 ]; then
    install_uaac
  fi
}

run_setup $@
