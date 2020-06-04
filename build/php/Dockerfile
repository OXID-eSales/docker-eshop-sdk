ARG PHP_VERSION=7.3
FROM php:${PHP_VERSION}-apache

ARG DEV_ENVIROMENT=PHPSTORM
ARG HOST_USER_ID
ARG HOST_GROUP_ID

ARG RUNTIME_PACKAGE_DEPS="msmtp libfreetype6 libjpeg62-turbo unzip git default-mysql-client sudo rsync liblz4-tool bc libonig5 libzip-dev vim"
ARG BUILD_PACKAGE_DEPS="libcurl4-openssl-dev libjpeg-dev libpng-dev libxml2-dev libonig-dev"
ARG PHP_EXT_DEPS="curl json xml mbstring zip bcmath soap pdo_mysql gd mysqli exif"
ARG PECL_DEPS="xdebug"
ARG PHP_MEMORY_LIMIT="-1"

ENV APACHE_DOCUMENT_ROOT /var/www/oxideshop/source/

SHELL ["/bin/bash", "-c"]

# install dependencies and cleanup (needs to be one step, as else it will cache in the laver)
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        $RUNTIME_PACKAGE_DEPS \
        $BUILD_PACKAGE_DEPS \
    && if [[ $PHP_VERSION = 7.4* ]]; \
       then docker-php-ext-configure gd --with-jpeg; \
       else docker-php-ext-configure gd --with-jpeg-dir=/usr/local; \
       fi \
    && if [[ $PHP_VERSION = 7.4* ]]; \
       then docker-php-ext-configure zip; \
       else docker-php-ext-configure zip --with-libzip=/usr/include; \
       fi \
    && docker-php-ext-install -j$(nproc) $PHP_EXT_DEPS \
    && pecl install $PECL_DEPS \
    && docker-php-ext-enable xdebug \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoremove -y \
    && apt-get purge -y --auto-remove $BUILD_PACKAGE_DEPS \
    && rm -rf /var/lib/apt/lists/* \
    && echo "sendmail_path=/usr/bin/msmtp -t" > /usr/local/etc/php/conf.d/php-sendmail.ini \
    && echo "memory_limit = $PHP_MEMORY_LIMIT" > /usr/local/etc/php/conf.d/memory-limit-php.ini \
    && echo "xdebug.remote_enable = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && if [[ $DEV_ENVIROMENT = PHPSTORM ]];then \
	    echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	;else \
	    echo "xdebug.remote_autostart = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
	    && echo "xdebug.remote_host = 172.17.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \ 
	;fi \
    && echo "xdebug.trace_enable_trigger = true" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.trace_output_dir = /var/www/oxideshop/debug/" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable_trigger = true" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_dir = /var/www/oxideshop/debug/" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && curl --silent --show-error https://getcomposer.org/installer | php \
    && mv /var/www/html/composer.phar /usr/local/bin/composer \
    && groupadd -f -g $HOST_GROUP_ID oxid \
    && useradd -m -d /home/oxid -s /bin/bash -g $HOST_GROUP_ID -u $HOST_USER_ID oxid \
    && echo "oxid ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && printf "host mailhog\nport 1025" >> /etc/msmtprc \
    && a2enmod rewrite \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && docker-php-ext-install opcache

ENV APACHE_RUN_USER=oxid
ENV APACHE_RUN_GROUP=oxid

WORKDIR /var/www/oxideshop
