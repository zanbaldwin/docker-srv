#!/bin/sh
php-fpm -R
nginx -g "daemon off;"
