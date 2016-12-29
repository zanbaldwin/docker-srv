FROM php:7.1-fpm-alpine
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
EXPOSE 9000
WORKDIR /srv

RUN apk add --no-cache libpng-dev gmp-dev icu-dev libmcrypt-dev sqlite-dev libxml2-dev libxslt-dev sed
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install dba
RUN docker-php-ext-install gd
RUN docker-php-ext-install gmp
RUN docker-php-ext-install hash
RUN docker-php-ext-install intl
RUN docker-php-ext-install json
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo_sqlite
RUN docker-php-ext-install session
RUN docker-php-ext-install simplexml
RUN docker-php-ext-install sockets
RUN docker-php-ext-install xml
RUN docker-php-ext-install xsl
RUN docker-php-ext-install zip

RUN sed -i -e 's/www-data/root/g' /usr/local/etc/php-fpm.d/www.conf

RUN apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /usr/local/bin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /usr/local/bin/dumb-init
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]
CMD [ "php-fpm", "--allow-to-run-as-root", "--nodaemonize" ]
