#!/bin/bash

#BASE_RELEASE_SH="https://github.build.ge.com/raw/adoption/Org-migration/master/base_release.sh"
#eval "$(curl -s -L $BASE_RELEASE_SH)"


function __find_n_sed() {
  find . -type f -not -iname "*/.git/*" -not -iname "./scripts/release.sh" -exec sed -i -e $1 {} \;
}


__find_n_sed "s;github.build.ge.com/raw/adoption;raw.githubusercontent.com/PredixDev;g"
__find_n_sed "s;github.build.ge.com/adoption;github.com/PredixDev;g"

find . -type f -name '*.bat' -exec unix2dos '{}' +
