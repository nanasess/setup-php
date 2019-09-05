#!/bin/bash

set -eo pipefail

release=$(lsb_release -cs)
version=$1

sudo apt install -y software-properties-common

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y build-essential debconf-utils unzip autogen autoconf libtool pkg-config

sudo apt-get install -y \
     php${version}-bcmath \
     php${version}-bz2 \
     php${version}-cgi \
     php${version}-cli \
     php${version}-common \
     php${version}-curl \
     php${version}-dba \
     php${version}-dev \
     php${version}-enchant \
     php${version}-gd \
     php${version}-intl \
     php${version}-json \
     php${version}-mbstring \
     php${version}-mysql \
     php${version}-odbc \
     php${version}-opcache \
     php${version}-pgsql \
     php${version}-phpdbg \
     php${version}-soap \
     php${version}-sqlite3 \
     php${version}-xml \
     php${version}-xmlrpc \
     php${version}-xsl \
     php${version}-zip

sudo update-alternatives --set php /usr/bin/php${version}
sudo update-alternatives --set phar /usr/bin/phar${version}
sudo update-alternatives --set phpdbg /usr/bin/phpdbg${version}
sudo update-alternatives --set php-cgi /usr/bin/php-cgi${version}
sudo update-alternatives --set phar.phar /usr/bin/phar.phar${version}
sudo phpdismod -s cli xdebug
php -version
