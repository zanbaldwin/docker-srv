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
    && apk add --no-cache \
        libpng-dev  libjpeg-turbo-dev   libwebp-dev     giflib-dev \
        gmp-dev     icu-dev             libmcrypt-dev   sqlite-dev \
        libxml2-dev libxslt-dev         sed             ssmtp \
    && echo 'sendmail_path="/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini \
    && echo 'FromLineOverride=YES' >> /etc/ssmtp/ssmtp.conf \
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
    && echo ";zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/pecl-xdebug.ini

CMD [ "php-fpm", "--allow-to-run-as-root", "--nodaemonize" ]

