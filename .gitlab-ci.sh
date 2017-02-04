#!/bin/bash

# Install dependencies only for Docker.
# [[ ! -e /.dockerinit ]] && exit 0   # <---- this fails with me
set -xe

# Update packages and install composer and PHP dependencies.
apt-get update -yqq
apt-get install git libcurl4-gnutls-dev libicu-dev libmcrypt-dev libvpx-dev libjpeg-dev libpng-dev libxpm-dev zlib1g-dev libfreetype6-dev libxml2-dev libexpat1-dev libbz2-dev libgmp3-dev libldap2-dev unixodbc-dev libpq-dev libsqlite3-dev libaspell-dev libsnmp-dev libpcre3-dev libtidy-dev -yqq

# For chromedriver tests
# ---- Laravel Dusk ----
apt-get install software-properties-common wget xvfb psmisc -yqq
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - # Chrome
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
apt-get update -yqq
apt-get install -yqq google-chrome-stable google-chrome-beta
export CHROME_BIN=$HOME/.chrome/chromium/chrome-linux/chrome
# ------------------------------

# Compile PHP, include these extensions.
# don't install mcrypt anymore
docker-php-ext-install mbstring pdo_mysql curl json intl gd xml zip bz2 opcache

# Install Composer and project dependencies.
curl -sS https://getcomposer.org/installer | php
php composer.phar install

# Copy over testing configuration.
cp .env.testing .env

# Generate an application key. Re-cache.
php artisan key:generate
# Clean config cache for testing
php artisan config:cache

# Run database migrations.
php artisan migrate

# Run database seeder (optional)
# php artisan db:seed --class=UserTableSeeder
