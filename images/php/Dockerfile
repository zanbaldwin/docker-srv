FROM php:7.1-fpm-alpine
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
WORKDIR /srv
EXPOSE 9000

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

RUN sed -i -e 's/www-data/root/g' /usr/local/etc/php-fpm.d/www.conf \
    && apk add --no-cache --virtual .extension-build-deps \
        libpng-dev      libjpeg-turbo-dev   libwebp-dev     giflib-dev \
        gmp-dev         icu-dev             libmcrypt-dev   sqlite-dev \
        libxml2-dev     libxslt-dev         sed \
    && apk add --no-cache --virtual .extension-runtime-deps \
        libpng          libjpeg-turbo       libwebp         giflib \
        gmp             icu                 libmcrypt       sqlite \
        libxml2         libxslt             ssmtp           openssl \
    && echo 'sendmail_path="/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini \
    && echo 'FromLineOverride=YES' >> /etc/ssmtp/ssmtp.conf \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr \
    && docker-php-ext-install \
        bcmath          dba                 exif            gd \
        gmp             hash                intl            json \
        mbstring        mcrypt              mysqli          opcache \
        pdo             pdo_mysql           pdo_sqlite      session \
        simplexml       sockets             xml             xsl \
        zip \
    && apk del .extension-build-deps

# Add Extensions for Asynchronous PHP
RUN    apk add --no-cache --virtual .event-build-deps \
        $PHPIZE_DEPS    libevent-dev       openssl-dev \
    && apk add --no-cache --virtual .event-runtime-deps libevent openssl \
    && pecl install ev \
    # Would love to not have to install the event extension, but unfortunately
    # support for the ev extension isn't as widespread as I would like.
    && pecl install event \
    && touch /usr/local/etc/php/conf.d/pecl-ev.ini \
    && touch /usr/local/etc/php/conf.d/pecl-event.ini \
    && echo "extension=ev.so" > /usr/local/etc/php/conf.d/pecl-ev.ini \
    && echo "extension=event.so" > /usr/local/etc/php/conf.d/pecl-event.ini \
    && apk del .event-build-deps

RUN apk add --no-cache --virtual .xdebug-build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && touch /usr/local/etc/php/conf.d/pecl-xdebug.ini \
    && echo ";zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/pecl-xdebug.ini \
    && apk del .xdebug-build-deps

CMD [ "php-fpm", "--allow-to-run-as-root", "--nodaemonize" ]

