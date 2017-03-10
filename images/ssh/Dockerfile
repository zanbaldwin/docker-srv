FROM alpine:3.5
MAINTAINER Zander Baldwin <hello@zanderbaldwin.com>
WORKDIR /srv
EXPOSE 22

RUN apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /sbin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /sbin/dumb-init
ENTRYPOINT [ "/sbin/dumb-init", "--" ]

ENV TERM xterm
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN apk add --no-cache bash bash-completion curl nano git openssh ncurses \
    && mkdir /var/run/sshd \
    && sed -i -e "s@/bin/ash@/bin/bash@g" /etc/passwd \
    && ssh-keygen -A
RUN curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o /etc/profile.d/00-git_prompt.sh \
    && curl https://raw.githubusercontent.com/zanderbaldwin/dotfiles/master/.bash_aliases -o /etc/profile.d/10-bash-aliases.sh \
    && curl https://raw.githubusercontent.com/zanderbaldwin/dotfiles/master/.bash_prompt -o /etc/profile.d/20-bash-prompt.sh \
    && echo "cd /srv" > /etc/profile.d/30-srv-directory.sh \
    && mkdir /root/.ssh && touch /root/.ssh/authorized_keys

CMD [ "/usr/sbin/sshd", "-D" ]
