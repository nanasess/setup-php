#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

install_openssl1_0()
{
    cd /tmp
    curl -L -O https://github.com/openssl/openssl/archive/OpenSSL_1_0_2p.tar.gz
    tar xf OpenSSL_1_0_2p.tar.gz
    cd openssl-OpenSSL_1_0_2p
    ./config -fPIC shared --prefix=/usr/local --openssldir=/usr/local/openssl
    make -j $(nproc)
    sudo make install
}

install_postgresql()
{
    cd /tmp
    curl -L -O https://ftp.postgresql.org/pub/source/v9.6.15/postgresql-9.6.15.tar.bz2
    tar xf postgresql-9.6.15.tar.bz2
    cd postgresql-9.6.15
    ./configure --prefix=/usr/local
    make -j $(nproc)
    sudo make install
}

install_ext_openssl()
{
    cd $PHP_BUILD_TMPDIR/source/$MINOR_VERSION/ext/openssl
    cp config0.m4 config.m4
    $(phpenv root)/versions/${MINOR_VERSION}/bin/phpize
    ./configure --with-php-config=$(phpenv root)/versions/${MINOR_VERSION}/bin/php-config
    make -j $(nproc)
    sudo make install
    echo "extension=openssl.so" > $(phpenv root)/versions/${MINOR_VERSION}/etc/conf.d/openssl.ini
}

echo "RUNNER_TOOL_CACHE: ${RUNNER_TOOL_CACHE}"

git clone https://github.com/phpenv/phpenv.git $RUNNER_TOOL_CACHE/.phpenv
export PATH="$RUNNER_TOOL_CACHE/.phpenv/bin:$PATH"
eval "$(phpenv init -)"
git clone https://github.com/php-build/php-build $(phpenv root)/plugins/php-build

sudo apt-get update
# sudo apt-get purge 'php*'
sudo apt-get install -y libcurl4-nss-dev libjpeg-dev re2c libxml2-dev \
     libtidy-dev libxslt-dev libmcrypt-dev libreadline-dev libfreetype6-dev \
     zlib1g-dev libzip-dev mysql-client

sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl

install_openssl1_0
install_postgresql

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
--enable-bcmath
--with-freetype-dir=/usr
--with-pgsql=/usr/local
--with-pdo-pgsql
EOF

export PHP_BUILD_EXTRA_MAKE_ARGUMENTS="-j$(nproc)"
export PHP_BUILD_KEEP_OBJECT_FILES="on"
export PHP_BUILD_XDEBUG_ENABLE="off"
export PHP_BUILD_TMPDIR=/tmp/php-build
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

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
install_ext_openssl

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

php -i
