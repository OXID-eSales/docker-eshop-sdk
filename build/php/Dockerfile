ARG PHP_VERSION=8.0
FROM php:${PHP_VERSION}-apache

ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000

ARG RUNTIME_PACKAGE_DEPS="msmtp libfreetype6 libjpeg62-turbo unzip git default-mysql-client sudo rsync liblz4-tool bc libonig5 libzip-dev vim"
ARG BUILD_PACKAGE_DEPS="libcurl4-openssl-dev libjpeg-dev libpng-dev libxml2-dev libonig-dev"
ARG PHP8_EXT_DEPS="curl xml mbstring zip bcmath soap pdo_mysql gd mysqli exif opcache"
ARG PHP_EXT_DEPS="curl xml json mbstring zip bcmath soap pdo_mysql gd mysqli exif opcache"
ARG PECL_DEPS="xdebug"
ARG PHP_MEMORY_LIMIT="-1"
ARG PHP_HOST_IP="172.17.0.1"

ENV APACHE_DOCUMENT_ROOT /var/www/oxideshop/source/

# install dependencies and cleanup (needs to be one step, as else it will cache in the laver)
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        $RUNTIME_PACKAGE_DEPS \
        $BUILD_PACKAGE_DEPS \
    && if [ `expr substr $PHP_VERSION 1 3` = "7.4" ] || [ `expr substr $PHP_VERSION 1 2` = "8." ]; \
       then docker-php-ext-configure gd --with-jpeg; \
       else docker-php-ext-configure gd --with-jpeg-dir=/usr/local; \
       fi \
    && if [ `expr substr $PHP_VERSION 1 3` = "7.4" ] || [ `expr substr $PHP_VERSION 1 2` = "8." ]; \
       then docker-php-ext-configure zip; \
       else docker-php-ext-configure zip --with-libzip=/usr/include; \
       fi \
    && if [ `expr substr $PHP_VERSION 1 2` = "8." ]; \
       then docker-php-ext-install -j$(nproc) $PHP8_EXT_DEPS; \
       else docker-php-ext-install -j$(nproc) $PHP_EXT_DEPS; \
       fi \
    && pecl install $PECL_DEPS \
    && docker-php-ext-enable xdebug \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoremove -y \
    && apt-get purge -y --auto-remove $BUILD_PACKAGE_DEPS \
    && rm -rf /var/lib/apt/lists/* \
    && echo "sendmail_path=/usr/bin/msmtp -t" > /usr/local/etc/php/conf.d/php-sendmail.ini \
    && echo "memory_limit = $PHP_MEMORY_LIMIT" > /usr/local/etc/php/conf.d/memory-limit-php.ini \
    && groupadd -f -g $HOST_GROUP_ID oxid \
    && useradd -m -d /home/oxid -s /bin/bash -g $HOST_GROUP_ID -u $HOST_USER_ID oxid \
    && echo "oxid ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && printf "host mailhog\nport 1025" >> /etc/msmtprc \
    && a2enmod rewrite \
    && sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf \
    && sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

COPY xdebug.ini /tmp/docker-php-ext-xdebug.ini

RUN cat /tmp/docker-php-ext-xdebug.ini >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini  && rm -f /tmp/docker-php-ext-xdebug.ini

ENV XDEBUG_CONFIG="remote_mode=req remote_host=$PHP_HOST_IP remote_connect_back=0"

ENV APACHE_RUN_USER=oxid
ENV APACHE_RUN_GROUP=oxid

WORKDIR /var/www/oxideshop
