#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

sudo apt-get update
sudo apt-get purge 'php*'

export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"

export PHP_BUILD_EXTRA_MAKE_ARGUMENTS="-j$(nproc)"
export PHP_BUILD_CONFIGURE_OPTS="--with-freetype-dir=/usr --with-pdo-pgsql"
export PHP_BUILD_KEEP_OBJECT_FILES="on"

case "$version" in
    "5.4" )
        phpenv install -v -s 5.4.45
        ;;
    "5.5" )
        phpenv install -v -s 5.5.38
        ;;
esac

php --version
