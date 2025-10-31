ARG PHP_VERSION

FROM oxidesales/oxideshop-docker-php:$PHP_VERSION

ARG HOST_USER_ID
ARG HOST_USER_NAME
ARG HOST_GROUP_ID
ARG HOST_GROUP_NAME
ARG SMTP_HOST
ARG SMTP_PORT

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY custom.ini /usr/local/etc/php/conf.d/zcustom.ini

# add redis
ARG INSTALL_REDIS_EXTENSION=false
RUN if [ "$INSTALL_REDIS_EXTENSION" = "true" ]; then \
    pecl install redis \
    && docker-php-ext-enable redis; \
fi

# set sendmail for php to ssmtp
RUN printf "host mailpit\nport 1025" >> /etc/msmtprc

RUN groupadd -f -g $HOST_GROUP_ID $HOST_GROUP_NAME && \
    useradd -m -d /home/$HOST_USER_NAME -s /bin/bash -g $HOST_GROUP_ID -u $HOST_USER_ID $HOST_USER_NAME || true && \
    echo "$HOST_USER_NAME  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R $HOST_USER_NAME:$HOST_GROUP_NAME /var/www/

RUN mkdir /home/$HOST_USER_NAME/.ssh && \
    ssh-keyscan -t rsa github.com >> /home/$HOST_USER_NAME/.ssh/known_hosts

WORKDIR /var/www/
