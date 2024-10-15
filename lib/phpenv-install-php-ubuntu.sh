#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

install_openssl1_0()
{
    cd /tmp
    curl -L --retry-connrefused --retry 10 --retry-delay 10 --max-time 30 -O https://github.com/openssl/openssl/archive/OpenSSL_1_0_2p.tar.gz
    tar xf OpenSSL_1_0_2p.tar.gz
    cd openssl-OpenSSL_1_0_2p
    ./config -fPIC shared --prefix=/usr/local --openssldir=/usr/local/openssl
    make -j $(nproc)
    sudo make install
}

install_postgresql()
{
    cd /tmp
    curl -L --retry-connrefused --retry 10 --retry-delay 10 --max-time 30 -O https://ftp.postgresql.org/pub/source/v9.6.15/postgresql-9.6.15.tar.bz2
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

if ! command -v apt-fast >/dev/null; then
    sudo ln -sf /usr/bin/apt-get /usr/bin/apt-fast
    trap "sudo rm -f /usr/bin/apt-fast 2>/dev/null" exit
fi

sudo apt-fast update

# sudo apt-get purge 'php*'
sudo apt-fast install -y libjpeg-dev re2c libxml2-dev \
     libtidy-dev libxslt1-dev libmcrypt-dev libreadline-dev libfreetype6-dev \
     libonig-dev zlib1g-dev

if [ $release == 'noble' ]
then
    sudo apt-fast install -y libcurl4-openssl-dev libsqlite3-dev
fi
if [ $release == 'bionic' ]
then
    sudo apt-fast install -y mysql-client libcurl4-nss-dev
fi
if [ $release == 'focal' ] || [ $release == 'jammy' ]
then
    sudo apt-fast install -y libzip-dev libmariadb-dev libfreetype-dev libcurl4-nss-dev
fi

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
--with-pgsql=/usr/local
--with-pdo-pgsql
EOF

# Since icu-config and freetype-config were disabled in Ubuntu-20.04 and later, enable the option only in PHP5.6 and later.
error_code=0
dpkg --compare-versions "$version" "lt" "5.6" || error_code=$?
if [ "$error_code" -eq 1 ]
then
    echo "--enable-intl" >> $(phpenv root)/plugins/php-build/share/php-build/default_configure_options
    echo "--with-freetype-dir=/usr" >> $(phpenv root)/plugins/php-build/share/php-build/default_configure_options
fi

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

if [[ $version = 8.2snapshot ]]
then
    git clone -b PHP-8.2 https://github.com/php/php-src.git ${PHP_BUILD_TMPDIR}/source/${version}
    cat ${PHP_BUILD_TMPDIR}/source/${version}/main/php_version.h
else
    curl -L --retry-connrefused --retry 10 --retry-delay 10 --max-time 30 -o ${PHP_BUILD_TMPDIR}/packages/php-${version}.tar.bz2 https://www.php.net/distributions/php-${version}.tar.bz2
    tar -x --strip-components 1 -f ${PHP_BUILD_TMPDIR}/packages/php-${version}.tar.bz2 -C ${PHP_BUILD_TMPDIR}/source/${version}
fi

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
