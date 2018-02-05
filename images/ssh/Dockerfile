FROM alpine:3.7
MAINTAINER Zan Baldwin <hello@zanbaldwin.com>
WORKDIR /srv
EXPOSE 22

RUN    apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /sbin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /sbin/dumb-init
ENTRYPOINT [ "/sbin/dumb-init", "--" ]

ENV TERM xterm
ENV COMPOSER_ALLOW_SUPERUSER 1
COPY motd /etc/motd

# Add and Setup Default Software
RUN    apk update \
    && apk add bash bash-completion curl nano git openssh ncurses mysql-client \
    && mkdir /var/run/sshd \
    && sed -i -e "s@/bin/ash@/bin/bash@g" /etc/passwd \
    && ssh-keygen -A

# Setup Shell Enironment
RUN    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o /etc/profile.d/00-git_prompt.sh \
    && curl https://raw.githubusercontent.com/zanderbaldwin/dotfiles/master/.bash_aliases -o /etc/profile.d/10-bash-aliases.sh \
    && curl https://raw.githubusercontent.com/zanderbaldwin/dotfiles/master/.bash_prompt -o /etc/profile.d/20-bash-prompt.sh \
    && echo "cd /srv" > /etc/profile.d/30-srv-directory.sh \
    && mkdir /root/.ssh && touch /root/.ssh/authorized_keys

# Install Composer (including a wide variety of libraries that most packages would need)
RUN    apk add php7 \
        php7-bcmath     php7-ctype      php7-curl       php7-dba        php7-dev \
        php7-dom        php7-exif       php7-gd         php7-gettext    php7-gmp \
        php7-iconv      php7-intl       php7-json       php7-mbstring   php7-mysqli \
        php7-mysqlnd    php7-opcache    php7-openssl    php7-pear       php7-pcntl \
        php7-pdo        php7-pdo_mysql  php7-pdo_sqlite php7-phar       php7-phpdbg \
        php7-session    php7-sockets    php7-sqlite3    php7-xml        php7-xmlreader \
        php7-xsl        php7-zip        php7-zlib \
    && (ln -s /usr/bin/php7 /usr/bin/php 2>/dev/null || true) \
    && sed -i "s/-C -n -q/-C -q/i" $(which pecl) \
    && EXPECTED_SIGNATURE=$(curl https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
    && ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');") \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
        exit 1; \
    fi; \
    php /tmp/composer-setup.php --install-dir="/usr/local/bin" --filename="composer"

CMD [ "/usr/sbin/sshd", "-D" ]
