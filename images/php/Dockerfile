FROM php:7.1-fpm-alpine
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
WORKDIR /srv
EXPOSE 9000

RUN apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /usr/local/bin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /usr/local/bin/dumb-init
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]

ENV COMPOSER_ALLOW_SUPERUSER 1

COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY php.ini /usr/local/etc/php/php.ini

RUN sed -i -e 's/www-data/root/g' /usr/local/etc/php-fpm.d/www.conf \
    && apk add --no-cache \
        libpng-dev  libjpeg-turbo-dev   libwebp-dev     giflib-dev \
        gmp-dev     icu-dev             libmcrypt-dev   sqlite-dev \
        libxml2-dev libxslt-dev         sed \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr \
    && docker-php-ext-install \
        bcmath      dba         exif        gd      gmp     hash    intl \
        json        mbstring    mcrypt      mysqli  opcache pdo     pdo_mysql \
        pdo_sqlite  session     simplexml   sockets xml     xsl     zip

RUN apk add --no-cache --virtual .xdebug-deps autoconf gcc make \
    && pecl install xdebug \
    && apk del .xdebug-deps \
    && touch /usr/local/etc/php/conf.d/xdebug.ini \
    && ( \
        echo ";zend_extension=xdebug.so"; \
        echo "xdebug.remote_enable=1"; \
        echo "xdebug.remote_handler=dbgp"; \
        echo "xdebug.remote_port=9000"; \
        echo "xdebug.remote_autostart=1"; \
        echo "xdebug.remote_connect_back=1"; \
        echo "xdebug.idekey=XDEBUG"; \
    ) >> /usr/local/etc/php/conf.d/xdebug.ini

CMD [ "php-fpm", "--allow-to-run-as-root", "--nodaemonize" ]

