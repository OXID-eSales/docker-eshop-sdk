ARG NGINX_VERSION

FROM nginx:$NGINX_VERSION

RUN mkdir -p /var/www/cache/oxid-main
RUN mkdir -p /var/www/cache/oxid-media

RUN apt-get update && \
    apt-get install nginx-extras -y
