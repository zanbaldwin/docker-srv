FROM php:7.1-fpm-alpine
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
EXPOSE 9000
WORKDIR /srv

COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
RUN apk add --no-cache libpng-dev gmp-dev icu-dev libmcrypt-dev sqlite-dev libxml2-dev libxslt-dev sed
RUN docker-php-ext-install \
    bcmath \
    dba \
    gd \
    gmp \
    hash \
    intl \
    json \
    mbstring \
    mcrypt \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    pdo_sqlite \
    session \
    simplexml \
    sockets \
    xml \
    xsl \
    zip

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
COPY php.ini /usr/local/etc/php/php.ini
