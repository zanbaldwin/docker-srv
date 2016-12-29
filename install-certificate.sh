#!/usr/bin/env bash
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Please supply a domain for the first argument (without www)." 1>&2
    exit 1
fi

docker exec nginx nginx -t && docker stop nginx && letsencrypt certonly --standalone -d $1 -d www.$1 && docker start nginx
