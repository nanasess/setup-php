#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

# Suppression to startup failure
if [ -f /lib/systemd/system/php${version}-fpm.service ]
then
    sudo systemctl disable php${version}-fpm
fi

sudo apt-get update

if [[ $version = '5.6' ]] \
       || [[ $version = '8.2' ]] \
       || [[ $release = 'jammy' && `echo "$version < 8.1" | bc` == 1 ]] \
       || [[ $release = 'focal' && `echo "$version < 7.4 || $version >= 8.0" | bc` == 1 ]] \
       || [[ $release = 'bionic' && `echo "$version < 7.4 || $version >= 8.0" | bc` == 1 ]]
then
    sudo add-apt-repository ppa:ondrej/php
    sudo apt-fast install -y build-essential debconf-utils unzip autogen autoconf libtool pkg-config

    sudo apt-fast install -y \
         php${version}-bcmath \
         php${version}-bz2 \
         php${version}-cgi \
         php${version}-cli \
         php${version}-common \
         php${version}-curl \
         php${version}-dba \
         php${version}-enchant \
         php${version}-gd \
         php${version}-mbstring \
         php${version}-mysql \
         php${version}-odbc \
         php${version}-opcache \
         php${version}-pgsql \
         php${version}-readline \
         php${version}-soap \
         php${version}-sqlite3 \
         php${version}-xml \
         php${version}-xsl \
         php${version}-zip
fi

if [[ $release = 'focal' && `echo "$version < 8.0" | bc` == 1 ]]
then
    if [[ "${version}" = "7.4" ]]; then
        sudo apt install php${version}-common=7.4.3-4ubuntu2.16 -y --allow-downgrades
    fi
    sudo apt-fast install -y \
         php${version}-json \
         php${version}-xmlrpc
fi

sudo apt-fast install -y \
     php${version}-dev \
     php${version}-phpdbg \
     php${version}-intl \
     php${version}-xml

sudo update-alternatives --set php /usr/bin/php${version}
sudo update-alternatives --set phar /usr/bin/phar${version}
sudo update-alternatives --set phpdbg /usr/bin/phpdbg${version}
# sudo update-alternatives --set php-cgi /usr/bin/php-cgi${version}
# sudo update-alternatives --set phar.phar /usr/bin/phar.phar${version}
sudo phpdismod -s cli xdebug

sudo bash -c 'echo "opcache.enable_cli=1" >> /etc/php/'$version'/cli/conf.d/10-opcache.ini'
sudo bash -c 'echo "apc.enable_cli=1" >> /etc/php/'$version'/cli/conf.d/20-apcu.ini'
