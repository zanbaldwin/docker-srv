ARG PHP_VERSION="7.2-fpm-alpine3.7"
FROM "php:${PHP_VERSION}"
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
WORKDIR /srv
EXPOSE 9000
EXPOSE 9001

RUN apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /sbin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /sbin/dumb-init
ENTRYPOINT [ "/sbin/dumb-init", "--" ]

ENV COMPOSER_ALLOW_SUPERUSER 1

COPY php.ini /usr/local/etc/php/php.ini

# Add Extension included in PHP Source Code
RUN sed -i -e 's/www-data/root/g' /usr/local/etc/php-fpm.d/www.conf \
    && apk add --no-cache --virtual .extension-build-deps \
        libpng-dev      libjpeg-turbo-dev   libwebp-dev     giflib-dev \
        gmp-dev         icu-dev             libxslt-dev     gettext-dev \
    && apk add --no-cache --virtual .extension-runtime-deps \
        libpng          libjpeg-turbo       libwebp         giflib \
        gmp             icu                 libxslt         ssmtp \
        openssl         gettext \
    && echo 'sendmail_path="/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini \
    && echo 'FromLineOverride=YES' >> /etc/ssmtp/ssmtp.conf \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr \
    && docker-php-ext-install \
        bcmath      dba         exif        gd          gettext     gmp     intl \
        mysqli      opcache     pcntl       pdo_mysql   sockets     xsl     zip \
    && apk del .extension-build-deps

# Add Extensions from PECL
RUN    apk add --no-cache --virtual .pecl-build-deps $PHPIZE_DEPS \
    # Ev PECL Extension.
    # Install this instead of the Event PECL extension (since it pollutes the global
    # namespace with a class called Event that clashes with some old-school
    # frameworks/applications).
    && pecl install ev \
    && echo "extension=ev.so" > /usr/local/etc/php/conf.d/pecl-ev.ini \
    # Redis PECL Extension.
    && pecl install redis \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/pecl-redis.ini \
    # XDebug Extension (disabled by default).
    # XDebug lags behind PHP at the moment, so it will fail silently.
    # Once XDebug releases a version that is compatible with the version of PHP
    # used in this image, it will automatically be added on build.
    && (pecl install xdebug || true) \
    && echo ";zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/pecl-xdebug.ini \
    && apk del .pecl-build-deps

CMD [ "php-fpm", "--allow-to-run-as-root", "--nodaemonize" ]

