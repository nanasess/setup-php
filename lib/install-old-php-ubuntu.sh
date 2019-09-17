#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

echo "RUNNER_TOOL_CACHE: ${RUNNER_TOOL_CACHE}"

sudo apt-get update
# sudo apt-get purge 'php*'
sudo apt-get install -y libcurl4-nss-dev libjpeg-dev re2c libxml2-dev \
     libtidy-dev libxslt-dev libmcrypt-dev libreadline-dev libfreetype6-dev \
     libpq-dev libpq5 zlib1g-dev libzip-dev mysql-client

sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl

export PATH="$RUNNER_TOOL_CACHE/.phpenv/bin:$PATH"
eval "$(phpenv init -)"

cat <<EOF > $(phpenv root)/plugins/php-build/share/php-build/default_configure_options
--without-pear
--with-gd
--enable-sockets
--with-jpeg-dir=/usr
--with-png-dir=/usr
--enable-exif
--enable-zip
--with-zlib
--with-zlib-dir=/usr
--with-bz2
--enable-intl
--with-kerberos
--enable-soap
--enable-xmlreader
--with-xsl
--enable-ftp
--enable-cgi
--with-curl=/usr
--with-tidy
--with-xmlrpc
--enable-sysvsem
--enable-sysvshm
--enable-shmop
--with-mysqli=mysqlnd
--with-pdo-mysql=mysqlnd
--with-pdo-sqlite
--enable-pcntl
--with-readline
--enable-mbstring
--disable-debug
--enable-fpm
--enable-bcmath
--enable-phpdbg
--with-freetype-dir=/usr
--with-pdo-pgsql
EOF

export PHP_BUILD_EXTRA_MAKE_ARGUMENTS="-j$(nproc)"
export PHP_BUILD_KEEP_OBJECT_FILES="on"

MINOR_VERSION=$version
case "$version" in
    "5.4" )
        MINOR_VERSION="5.4.45"
        ;;
    "5.5" )
        MINOR_VERSION="5.5.38"
        ;;
esac

phpenv install -v -s $MINOR_VERSION

# disable to xdebug
rm $(phpenv root)/versions/${MINOR_VERSION}/etc/conf.d/xdebug.ini

sudo update-alternatives --install /usr/bin/php php $(phpenv root)/versions/${MINOR_VERSION}/bin/php 10
sudo update-alternatives --install /usr/bin/phar phar $(phpenv root)/versions/${MINOR_VERSION}/bin/phar 10
# sudo update-alternatives --install /usr/bin/phpdbg phpdbg $(phpenv root)/versions/${MINOR_VERSION}/bin/phpdbg 10
sudo update-alternatives --install /usr/bin/php-cgi php-cgi $(phpenv root)/versions/${MINOR_VERSION}/bin/php-cgi 10
sudo update-alternatives --install /usr/bin/phar.phar phar.phar $(phpenv root)/versions/${MINOR_VERSION}/bin/phar.phar 10

sudo update-alternatives --set php $(phpenv root)/versions/${MINOR_VERSION}/bin/php
sudo update-alternatives --set phar $(phpenv root)/versions/${MINOR_VERSION}/bin/phar
# sudo update-alternatives --set phpdbg $(phpenv root)/versions/${MINOR_VERSION}/bin/phpdbg
sudo update-alternatives --set php-cgi $(phpenv root)/versions/${MINOR_VERSION}/bin/php-cgi
sudo update-alternatives --set phar.phar $(phpenv root)/versions/${MINOR_VERSION}/bin/phar.phar

php --version
