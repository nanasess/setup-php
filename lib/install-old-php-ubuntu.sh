#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

sudo apt-get update
sudo apt-get purge 'php*'

if [[ ! -d ~/.phpenv ]]
then
    git clone https://github.com/phpenv/phpenv.git ~/.phpenv
    echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(phpenv init -)"' >> ~/.bash_profile
    exec $SHELL -l
fi

PHP_BUILD_ROOT=$(phpenv root)/plugins/php-build
if [[ ! -d $PHP_BUILD_ROOT ]]
then
    git clone https://github.com/php-build/php-build $PHP_BUILD_ROOT
    PHP_BUILD_EXTRA_MAKE_ARGUMENTS="-j$(nproc)"
    PHP_BUILD_CONFIGURE_OPTS="--with-freetype-dir=/usr --with-pdo-pgsql"
fi

case "$version" in
    "5.4" )
        phpenv install 5.4.45
        ;;
    "5.5" )
        phpenv install 5.5.38
        ;;
esac

php --version
