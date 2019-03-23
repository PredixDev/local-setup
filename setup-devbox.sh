#!/bin/bash
set -e

git=0
cf=1
jdk=2
maven=3
nodejs=4
python2=5
python3=6
uaac=7
jq=8
predixcli=9
mobilecli=10
androidstudio=11
docker=12
vmware=13

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
    echo ""
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
}

function get_proxy_scripts() {
  VERIFY_PROXY_URL=https://raw.githubusercontent.com/PredixDev/predix-scripts/master/bash/common/proxy/verify-proxy.sh
  TOGGLE_PROXY_URL=https://raw.githubusercontent.com/PredixDev/predix-scripts/master/bash/common/proxy/toggle-proxy.sh
  ENABLE_XSL_URL=https://raw.githubusercontent.com/PredixDev/predix-scripts/master/bash/common/proxy/enable-proxy.xsl
  DISABLE_XSL_URL=https://raw.githubusercontent.com/PredixDev/predix-scripts/master/bash/common/proxy/disable-proxy.xsl

  if [ -f "verify-proxy.sh" ]; then
    rm verify-proxy.sh
  fi
  if [ -f "toggle-proxy.sh" ]; then
    rm toggle-proxy.sh
  fi
  if [ -f "enable-proxy.xsl" ]; then
    rm enable-proxy.xsl
  fi
  if [ -f "disable-proxy.xsl" ]; then
    rm disable-proxy.xsl
  fi

  if [ ! -f "verify-proxy.sh" ]; then
    curl -s -O $VERIFY_PROXY_URL
  fi
  if [ ! -f "toggle-proxy.sh" ]; then
    curl -s -O $TOGGLE_PROXY_URL
  fi
  if [ ! -f "enable-proxy.xsl" ]; then
    curl -s -O $ENABLE_XSL_URL
  fi
  if [ ! -f "disable-proxy.xsl" ]; then
    curl -s -O $DISABLE_XSL_URL
  fi
}


function install_everything() {
  install[git]=1
  install[cf]=1
  install[jdk]=1
  install[maven]=1
  install[nodejs]=1
  install[python2]=1
  install[python3]=1
  install[uaac]=0 # Install UAAC only if the --uaac flag is provided
  install[jq]=1
  install[yq]=1
  install[predixcli]=1
  install[mobilecli]=1
  install[androidstudio]=0 # Install Android Studio only if --androidstudio flag is provided
  install[docker]=1
  install[vmware]=0 # Install Android Studio only if --vmware flag is provided
}

function install_nothing() {
  install[git]=0
  install[cf]=0
  install[jdk]=0
  install[maven]=0
  install[nodejs]=0
  install[python2]=0
  install[python3]=0
  install[uaac]=0
  install[jq]=0
  install[yq]=0
  install[predixcli]=0
  install[mobilecli]=0
  install[androidstudio]=0
  install[docker]=0
  install[vmware]=0
}

function install_yq() {
  sudo pip install yq
  yq --version
}


function install_predixcli() {
  export DYLD_INSERT_LIBRARIES=;
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
    pm
  else
    #cli_url=$(curl -g -s -L https://api.github.com/repos/PredixDev/predix-mobile-cli/releases | jq -r '.' )
    cli_url=$(curl -g -s -L https://api.github.com/repos/PredixDev/predix-mobile-cli/releases | jq -r '[ .[] | select(.prerelease==false) ] | .[0].assets[]  |  select(.name | contains("Mac")) | .browser_download_url' )
    cli_install_url="https://raw.githubusercontent.com/PredixDev/local-setup/master/mobile-cli-install"
    cli_install_root_url="https://raw.githubusercontent.com/PredixDev/local-setup/master/mobile-cli-root-install"
    #cli_install_url="https://raw.githubusercontent.com/PredixDev/local-setup/develop/mobile-cli-install.sh"
    echo "Downloading latest Predix Mobile CLI: $cli_url"
    curl -L "$cli_url" -o pm.zip
    mkdir -p mobile-cli && tar -xf pm.zip -C mobile-cli
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
      [ "$1" == "--nodejs" ] && install[nodejs]=1
      [ "$1" == "--python2" ] && install[python2]=1
      [ "$1" == "--python3" ] && install[python3]=1
      [ "$1" == "--uaac" ] && install[uaac]=1
      [ "$1" == "--jq" ] && install[jq]=1
      [ "$1" == "--yq" ] && install[yq]=1
      [ "$1" == "--predixcli" ] && install[predixcli]=1
      [ "$1" == "--mobilecli" ] && install[mobilecli]=1
      [ "$1" == "--androidstudio" ] && install[androidstudio]=1
      [ "$1" == "--docker" ] && install[docker]=1
      [ "$1" == "--vmware" ] && install[vmware]=1
      shift
    done
    install[jq]=1
  fi

  check_internet
  check_bash_profile

  if [ ${install[jq]} -eq 1 ]; then
    echo "jq already installed"
  fi

  if [ ${install[yq]} -eq 1 ]; then
    install_yq
  fi

  if [ ${install[git]} -eq 1 ]; then
    echo "git already installed"
  fi

  if [ ${install[cf]} -eq 1 ]; then
    echo "cf already installed"
  fi

  if [ ${install[jdk]} -eq 1 ]; then
    echo "jdk already installed"
  fi

  if [ ${install[maven]} -eq 1 ]; then
    echo "maven already installed"
  fi

  if [ ${install[nodejs]} -eq 1 ]; then
    echo "nodejs already installed"
  fi

  if [ ${install[python3]} -eq 1 ]; then
    echo "python3 already installed"
  fi
  if [ ${install[python2]} -eq 1 ]; then
    echo "python2 already installed"
  fi

  if [ ${install[uaac]} -eq 1 ]; then
    echo "uaac not supported"
  fi

  if [ ${install[predixcli]} -eq 1 ]; then
    install_predixcli
  fi

  if [ ${install[mobilecli]} -eq 1 ]; then
    echo "mobile cli already installed"
  fi

  if [ ${install[androidstudio]} -eq 1 ]; then
    echo "android studio already installed"
  fi

  if [ ${install[docker]} -eq 1 ]; then
    echo "docker already installed"
  fi

}

function check_status() {
  if [ $STATUS != 0 ]; then
    echo
  	echo "install for $TOOL failed"
  	read -p "Would you like to keep going? (y/n) > " -t 300 answer
    if [[ -z $answer ]]; then
        echo -n "Specify (yes/no)> "
        read answer
    fi
    if [[ ${answer:0:1} == "y" ]] || [[ ${answer:0:1} == "Y" ]]; then
  		echo
  		echo "Continuing to next tool installation"
  	else
  		echo
  		echo "Exiting ..."
  		exit 1
  	fi
  fi
}


run_setup $@
# Running Proxy Scripts
echo
echo "Pulling proxy scripts from predix-scripts"
get_proxy_scripts
echo
echo "Running verify-proxy.sh"
source verify-proxy.sh
