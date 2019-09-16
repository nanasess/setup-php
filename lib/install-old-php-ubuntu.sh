#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

echo "RUNNER_TOOL_CACHE: ${RUNNER_TOOL_CACHE}"

sudo apt-get update
# sudo apt-get purge 'php*'
sudo apt-get install -y libcurl4-nss-dev libjpeg-dev re2c libxml2-dev \
     libtidy-dev libxslt-dev libmcrypt-dev libreadline-dev libfreetype6-dev \
     zlib1g-dev libzip-dev libpq-dev libpq5 postgresql-client mysql-client

sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl

export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
export PATH="$RUNNER_TOOL_CACHE/.phpenv/bin:$PATH"
eval "$(phpenv init -)"

export PHP_BUILD_EXTRA_MAKE_ARGUMENTS="-j$(nproc)"
export PHP_BUILD_CONFIGURE_OPTS="--with-freetype-dir=/usr --with-pdo-pgsql"
export PHP_BUILD_KEEP_OBJECT_FILES="on"

# case "$version" in
#     "5.4" )
#         phpenv install -v -s 5.4.45
#         ;;
#     "5.5" )
#         phpenv install -v -s 5.5.38
#         ;;
# esac

php --version
