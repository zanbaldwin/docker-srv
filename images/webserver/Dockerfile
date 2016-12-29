FROM darsyn/php:1.0.0
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
EXPOSE 80
WORKDIR /srv

RUN apk add --no-cache nginx openssl curl \
    && rm -f /var/log/nginx/error.log && ln -s /dev/stderr /var/log/nginx/error.log \
    && rm -f /var/log/nginx/access.log && ln -s /dev/stdout /var/log/nginx/access.log
COPY nginx.conf /etc/nginx/nginx.conf
COPY server.conf /etc/nginx/conf.d/server.conf

COPY entrypoint.sh /entrypoint.sh
CMD [ "/bin/sh", "/entrypoint.sh" ]
