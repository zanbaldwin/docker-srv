FROM nginx:1.13.1-alpine
MAINTAINER Zander Baldwin "hello@zanderbaldwin.com"
WORKDIR /srv
EXPOSE 80

RUN apk add --no-cache --virtual .build-deps bash gcc git libc-dev make \
    && git clone git://github.com/Yelp/dumb-init.git /tmp/dumb-init \
    && (cd /tmp/dumb-init; git checkout $(git describe --tags); make) \
    && mv /tmp/dumb-init/dumb-init /sbin/dumb-init \
    && rm -rf /tmp/dumb-init \
    && apk del .build-deps \
    && chmod +x /sbin/dumb-init
ENTRYPOINT [ "/sbin/dumb-init", "--" ]

COPY nginx.conf  /etc/nginx/nginx.conf
COPY setup.conf  /etc/nginx/conf.d/00-setup.conf
COPY server.conf /etc/nginx/conf.d/10-default-server.conf

CMD [ "nginx", "-g", "'daemon off;'" ]
