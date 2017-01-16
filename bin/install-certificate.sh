#!/usr/bin/env bash

SCRIPT=$(basename "$0")
function display_usage() {
    echo "Usage:" 1>&2
    echo "    $SCRIPT <domain>" 1>&2
    echo "" 1>&2
    echo "Arguments:" 1>&2
    echo "    domain      The domain to fetch a certificate for (without www prefix)." 1>&2
    echo "" 1>&2
    echo "Description:" 1>&2
    echo "    Install a certificate from Let's Encrypt for the specified domain." 1>&2
}

function nginx_control {
    case $1 in
        stop)
            if [ "$NGINX_RUNNING" != "true" ]; then
                return
            fi
            $DOCKER stop $NGINX_CONTAINER
            ;;
        start)
            if [ "$NGINX_RUNNING" != "true" ]; then
                return true
            fi
            $DOCKER exec $NGINX_CONTAINER nginx -t 1>/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "Nginx configuration is not valid." 1>&2
                echo "Run \"{docker exec nginx} nginx -t\" for detailed output." 1>&2
                echo 1
            fi
            $DOCKER start $NGINX_CONTAINER
            ;;
        *)
            echo "Internal error (invalid nginx control command)." 1>&2
            exit 1
            ;;
    esac
}

if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

if [ $# -eq 0 ]; then
    display_usage
    exit 1
fi

NGINX_CONTAINER="nginx"
DOCKER=$(which docker)
if [ $? -ne 0 ]; then
    echo "Docker not installed."
    exit 1
fi
# Don't bother checking if user has access to Docker, we already know we are
# running as root.
NGINX_RUNNING=$($DOCKER inspect -f "{{.State.Running}}" $NGINX_CONTAINER)

nginx_control stop && letsencrypt certonly --standalone -d "$1" -d "www.$1" && nginx_control start
