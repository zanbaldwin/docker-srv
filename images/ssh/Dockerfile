FROM alpine:3.5
MAINTAINER Zander Baldwin <hello@zanderbaldwin.com>
WORKDIR /srv
EXPOSE 22

RUN apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /usr/local/bin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /usr/local/bin/dumb-init
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]

ENV TERM xterm

RUN apk add --no-cache bash bash-completion curl nano git openssh ncurses \
    && mkdir /var/run/sshd \
    && sed -i -e "s@/bin/ash@/bin/bash@g" /etc/passwd \
    && ssh-keygen -A
RUN git clone git://github.com/zanderbaldwin/dotfiles.git /tmp/.dotfiles \
    && curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o /etc/profile.d/00-git_prompt.sh \
    && mv /tmp/.dotfiles/.bash_aliases /etc/profile.d/10-bash_aliases.sh \
    && mv /tmp/.dotfiles/.bash_custom /etc/profile.d/10-bash_custom.sh \
    && mv /tmp/.dotfiles/.bash_prompt /etc/profile.d/10-bash_prompt.sh \
    && rm -rf /tmp/.dotfiles \
    && mkdir /root/.ssh && touch /root/.ssh/authorized_keys

CMD [ "/usr/sbin/sshd", "-D" ]
