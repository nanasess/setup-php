#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

cd /tmp
curl -L -O https://github.com/openssl/openssl/archive/OpenSSL_1_0_2p.tar.gz
tar xvzf OpenSSL_1_0_2p.tar.gz
cd openssl-OpenSSL_1_0_2p
./config -fPIC shared --prefix=/usr/local/ --openssldir=/usr/local/openssl
make && make test
sudo make install

sudo apt-get update
sudo apt-get purge 'php*'
sudo apt-get install -y libcurl4-openssl-dev libjpeg-dev re2c libxml2-dev \
     libtidy-dev libxslt-dev libmcrypt-dev libreadline-dev libfreetype6-dev \
     zlib1g-dev libzip-dev libpq-dev libpq5 postgresql-client mysql-client

sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl

export PATH="$RUNNER_TOOL_CACHE/.phpenv/bin:$PATH"
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
