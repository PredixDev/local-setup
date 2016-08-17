#!/bin/bash
set -e

echo "--------------------------------------------------------------"
echo "This script will install tools required for Predix development"
echo "You may be asked to provide your password during the installation process"
echo "--------------------------------------------------------------"

git=0
cf=1
jdk=2
maven=3
sts=4
nodejs=5
uaac=6

declare -a install

prefix_to_path() {
  if [[ ":$PATH:" != *":$1:"* ]]; then
    echo 'export PATH="$1${PATH:+":$PATH"}"' >> ~/.bash_profile
    source ~/.bash_profile
  fi
}

brew_install() {
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

brew_cask_install() {
  echo "--------------------------------------------------------------"
  TOOL=$1

  if brew cask list | grep $TOOL > /dev/null; then
    echo "$TOOL already installed"
  else
    echo "Installing $TOOL"
    brew cask install $TOOL
  fi
}

install_everything() {
  install[git]=1
  install[cf]=1
  install[jdk]=1
  install[maven]=1
  install[sts]=1
  install[nodejs]=1
  install[uaac]=0 # Install UAAC only if the --uaac flag is provided
}

install_nothing() {
  install[git]=0
  install[cf]=0
  install[jdk]=0
  install[maven]=0
  install[sts]=0
  install[nodejs]=0
  install[uaac]=0
}

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
    [ "$1" == "--uaac" ] && install[uaac]=1
    shift
  done
fi

echo "Checking internet connection..."

if [ $? -ne 0 ]; then
  echo Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy
  exit 1
fi
echo "OK"

# Ensure bash profile exists
if [ ! -e ~/.bash_profile ]; then
  printf "#!/bin/bash\n" >> ~/.bash_profile
fi

# This is required for brew to work
prefix_to_path /usr/local/bin

# Install brew and cask
if which brew > /dev/null; then
  echo "brew already installed, tapping cask"
else
  echo "Installing brew and cask"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew tap caskroom/cask

if [ ${install[git]} -eq 1 ]; then
  brew_install git
  git --version
fi

if [ ${install[cf]} -eq 1 ]; then
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
fi

if [ ${install[jdk]} -eq 1 ]; then
  brew_cask_install java
  javac -version
fi


if [ ${install[maven]} -eq 1 ]; then
  brew_install maven mvn
  mvn -v
fi

if [ ${install[sts]} -eq 1 ]; then
  brew_cask_install sts
fi

if [ ${install[nodejs]} -eq 1 ]; then
  brew_install node
  node -v
  brew_install npm
  npm -v

  type bower > /dev/null || npm install -g bower
  echo -ne "\nbower "
  bower -v

  type grunt > /dev/null || npm install -g grunt-cli
  grunt --version
fi

if [ ${install[uaac]} -eq 1 ]; then
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
fi
