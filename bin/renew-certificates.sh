#!/usr/bin/env bash

function nginx_control {
    case $1 in
        stop)
            if [ "${NGINX_RUNNING}" != "true" ]; then
                return 0
            fi
            ${DOCKER} stop ${NGINX_CONTAINER}
            ;;
        start)
            if [ "${NGINX_RUNNING}" != "true" ]; then
                return 0
            fi
            CONFIG=$(${DOCKER} exec ${NGINX_CONTAINER} nginx -t 1>/dev/null 2>&1)
            if [ $? -ne 0 ]; then
                echo "Nginx configuration is not valid." 1>&2
                echo "Run \"[docker exec nginx] nginx -t\" for detailed output." 1>&2
                echo 1
            fi
            ${DOCKER} start ${NGINX_CONTAINER}
            ;;
        *)
            echo "Internal error (invalid Nginx control command)." 1>&2
            exit 1
            ;;
    esac
}

if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root." 1>&2
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
NGINX_RUNNING=$(${DOCKER} inspect -f "{{.State.Running}}" ${NGINX_CONTAINER})

nginx_control stop && letsencrypt renew && nginx_control start
