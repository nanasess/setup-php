#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

install_openssl1_0()
{
    cd /tmp
    wget https://github.com/openssl/openssl/archive/OpenSSL_1_0_2p.tar.gz
    tar xf OpenSSL_1_0_2p.tar.gz
    cd openssl-OpenSSL_1_0_2p
    ./config -fPIC shared --prefix=/usr/local --openssldir=/usr/local/openssl
    make -j $(nproc)
    sudo make install
}

install_postgresql()
{
    cd /tmp
    wget https://ftp.postgresql.org/pub/source/v9.6.15/postgresql-9.6.15.tar.bz2
    tar xf postgresql-9.6.15.tar.bz2
    cd postgresql-9.6.15
    ./configure --prefix=/usr/local
    make -j $(nproc)
    sudo make install
}

install_ext_openssl()
{
    cd $PHP_BUILD_TMPDIR/source/$version/ext/openssl
    cp config0.m4 config.m4
    $(phpenv root)/versions/${version}/bin/phpize
    ./configure --with-php-config=$(phpenv root)/versions/${version}/bin/php-config
    make -j $(nproc)
    sudo make install
    echo "extension=openssl.so" > $(phpenv root)/versions/${version}/etc/conf.d/openssl.ini
}

git clone https://github.com/phpenv/phpenv.git $HOME/.phpenv
export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"
git clone https://github.com/php-build/php-build $(phpenv root)/plugins/php-build

sudo apt-fast update

# sudo apt-get purge 'php*'
if [ $release == 'xenial' ]
then
    sudo apt-fast purge 'libssl1.1'
    sudo apt-fast purge 'postgresql*'
fi
sudo apt-fast install -y libcurl4-nss-dev libjpeg-dev re2c libxml2-dev \
     libtidy-dev libxslt-dev libmcrypt-dev libreadline-dev libfreetype6-dev \
     libonig-dev zlib1g-dev libzip-dev mysql-client

sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl

install_openssl1_0
install_postgresql

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

if [ ! -d "${PHP_BUILD_TMPDIR}/packages" ]
then
    mkdir -p ${PHP_BUILD_TMPDIR}/packages
fi
if [ ! -d "${PHP_BUILD_TMPDIR}/source" ]
then
    mkdir -p ${PHP_BUILD_TMPDIR}/source
fi
if [ ! -d "${PHP_BUILD_TMPDIR}/source/${version}" ]
then
    mkdir -p ${PHP_BUILD_TMPDIR}/source/${version}
fi
wget --retry-connrefused --tries=10 --timeout=30  --inet4-only -P ${PHP_BUILD_TMPDIR}/packages/ https://secure.php.net/distributions/php-${version}.tar.bz2
tar -x --strip-components 1 -f ${PHP_BUILD_TMPDIR}/packages/php-${version}.tar.bz2 -C ${PHP_BUILD_TMPDIR}/source/${version}

phpenv install -v -s $version
install_ext_openssl

sudo update-alternatives --install /usr/bin/php php $(phpenv root)/versions/${version}/bin/php 10
sudo update-alternatives --install /usr/bin/phar phar $(phpenv root)/versions/${version}/bin/phar 10
# sudo update-alternatives --install /usr/bin/phpdbg phpdbg $(phpenv root)/versions/${version}/bin/phpdbg 10
sudo update-alternatives --install /usr/bin/php-cgi php-cgi $(phpenv root)/versions/${version}/bin/php-cgi 10
sudo update-alternatives --install /usr/bin/phar.phar phar.phar $(phpenv root)/versions/${version}/bin/phar.phar 10

sudo update-alternatives --set php $(phpenv root)/versions/${version}/bin/php
sudo update-alternatives --set phar $(phpenv root)/versions/${version}/bin/phar
# sudo update-alternatives --set phpdbg $(phpenv root)/versions/${version}/bin/phpdbg
sudo update-alternatives --set php-cgi $(phpenv root)/versions/${version}/bin/php-cgi
sudo update-alternatives --set phar.phar $(phpenv root)/versions/${version}/bin/phar.phar

php -i
