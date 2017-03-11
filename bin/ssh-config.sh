#!/bin/bash

DOCKER_GEN_CONTAINER=${DOCKER_GEN_CONTAINER:-"docker-gen"}
TEMPLATE=${TEMPLATE:-"ssh.conf"}

DOCKER=$(which docker)
if [ $? -ne 0 ]; then
    echo "Docker not installed."
    exit 1
fi

COMPOSE=$(which docker-compose)
if [ $? -ne 0 ]; then
    echo "Docker Compose not installed."
    exit 1
fi

INFO=$(${DOCKER} info 1>/dev/null 2>&1)
if [ $? -ne 0 ]; then
    echo "Docker not available."
    if [ $(id -u) -ne 0 ]; then
        echo "Please retry as root."
    fi
    exit 1
fi

${COMPOSE} run --rm ${DOCKER_GEN_CONTAINER} /etc/docker-gen/templates/${TEMPLATE}
