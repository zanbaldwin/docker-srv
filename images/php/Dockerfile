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

RUN    apk add --no-cache --virtual .xdebug-build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && touch /usr/local/etc/php/conf.d/pecl-xdebug.ini \
    && echo ";zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/pecl-xdebug.ini \
    && apk del .xdebug-build-deps

# Install Composer
RUN    curl "https://getcomposer.org/installer" -o "/tmp/composer-setup.php" \
    && EXPECTED_SIGNATURE="$(curl https://composer.github.io/installer.sig)" \
       ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")" \
       [ "${EXPECTED_SIGNATURE}" == "${ACTUAL_SIGNATURE}" ] || (echo  >&2 'ERROR: Invalid Composer installer signature'; exit 1;) \
    && php "/tmp/composer-setup.php" --install-dir="/usr/local/bin" --filename="composer" \
    && rm "/tmp/composer-setup.php"

# Install PHPUnit
RUN    curl "https://phar.phpunit.de/phpunit-5.7.phar" -o "/usr/local/bin/phpunit5" \
    && chmod +x "/usr/local/bin/phpunit5" \
    && curl "https://phar.phpunit.de/phpunit-6.0.phar" -o "/usr/local/bin/phpunit6" \
    && chmod +x "/usr/local/bin/phpunit6" \
    && ln -s "/usr/local/bin/phpunit5" "/usr/local/bin/phpunit"

CMD [ "php-fpm", "--allow-to-run-as-root", "--nodaemonize" ]

