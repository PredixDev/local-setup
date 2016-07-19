#!/bin/bash
set -e

echo "--------------------------------------------------------------"
echo "This script will install tools required for Predix development"
echo "You may be asked to provide your password during the installation process"
echo "--------------------------------------------------------------"

prefix_to_path() {
  if [[ ":$PATH:" != *":$1:"* ]]
  then
    echo 'export PATH="$1${PATH:+":$PATH"}"' >> ~/.bash_profile
    source ~/.bash_profile
  fi
}

brew_install() {
  TOOL=$1
  COMMAND=$1
  if [ $# -eq 2 ]
  then
    COMMAND=$2
  fi

  if which $COMMAND > /dev/null
  then
    echo "$TOOL already installed"
  else
    echo "Installing $TOOL"
    brew install $TOOL
  fi
}

# Ensure bash profile exists
if [ ! -e ~/.bash_profile ]
then
  printf "#!/bin/bash\n" >> ~/.bash_profile
fi

# This is required for brew to work
prefix_to_path /usr/local/bin

# Install brew and cask
if which brew > /dev/null
then
  echo "brew already installed, tapping cask"
else
  echo "Installing brew and cask"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew tap caskroom/cask

# Install tools for managing ruby
echo "--------------------------------------------------------------"
brew_install rbenv
brew_install ruby-build
# Add rbenv to bash
grep -q -F 'rbenv init' ~/.bash_profile || echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile
# Install latest ruby
RUBY_VERSION=`egrep "^\s+\d+\.\d+\.\d+$" <(rbenv install -l) | tail -1 | tr -d '[[:space:]]'`
echo "--------------------------------------------------------------"
if grep -q "$RUBY_VERSION" <(ruby -v)
then
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

# Install CF-Cli
echo "--------------------------------------------------------------"
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

# Install JDK
echo "--------------------------------------------------------------"
echo "Installing latest JDK"
brew cask install java
javac -version

# Install Git
echo "--------------------------------------------------------------"
brew_install git
git --version

# Install Maven
echo "--------------------------------------------------------------"
brew_install maven
mvn -v

# Install STS
echo "--------------------------------------------------------------"
echo "Installing latest STS"
brew cask install sts

# Install Node
echo "--------------------------------------------------------------"
brew_install node
# Install npm
brew_install npm
node -v

# Install bower
echo "--------------------------------------------------------------"
npm install -g bower
bower -v

# Install grunt
echo "--------------------------------------------------------------"
npm install -g grunt-cli
grunt --version

python --version
