FROM nginx:1.11.8-alpine
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
WORKDIR /srv
EXPOSE 80

RUN apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /usr/local/bin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /usr/local/bin/dumb-init
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]

COPY nginx.conf /etc/nginx/nginx.conf
COPY server.conf /etc/nginx/conf.d/default.conf

CMD [ "nginx", "-g", "daemon off;" ]
