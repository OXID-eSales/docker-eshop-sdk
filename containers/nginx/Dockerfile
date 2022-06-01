FROM nginx:latest

RUN mkdir -p /var/www/cache/oxid-main
RUN mkdir -p /var/www/cache/oxid-media

RUN apt-get update && \
    apt-get install nginx-extras -y
