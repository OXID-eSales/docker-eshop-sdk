FROM httpd:2.4-alpine

COPY custom.conf /usr/local/apache2/conf/custom.conf
COPY project.conf /usr/local/apache2/conf/project.conf

# Those are going to support default configuration
COPY certs/example.crt /usr/local/apache2/conf/server.crt
COPY certs/example.key /usr/local/apache2/conf/server.key

# Those are going to support localhost.local and oxideshop.local
COPY certs/ /usr/local/apache2/conf/

RUN printf "Include conf/custom.conf\n" >> /usr/local/apache2/conf/httpd.conf && \
    printf "Include conf/project.conf" >> /usr/local/apache2/conf/httpd.conf

RUN sed -i \
    -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
    -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
    -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
    conf/httpd.conf