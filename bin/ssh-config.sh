#!/bin/bash

DOCKER_GEN_CONTAINER=${DOCKER_GEN_CONTAINER:-"docker-gen"}
TEMPLATE=${TEMPLATE:-"ssh.conf"}

DOCKER=${DOCKER:-"docker"}
command -v "${DOCKER}" >/dev/null 2>&1 || { echo >&2 "Docker Client \"${DOCKER}\" not installed. Aborting!"; exit 1; }
# No need to resolve $DOCKER to an absolute path, since "command" has already
# determined it's an executable.

COMPOSE=${COMPOSE:-"docker-compose"}
command -v "${COMPOSE}" >/dev/null 2>&1 || { echo >&2 "Docker Compose \"${COMPOSE}\" not installed on \$PATH. Aborting!"; exit 1; }

INFO=$("${DOCKER}" info 1>/dev/null 2>&1)
if [ $? -ne 0 ]; then
    echo "Docker not available."
    if [ $(id -u) -ne 0 ]; then
        echo "Please retry as root."
    fi
    exit 1
fi

"${COMPOSE}" run --rm "${DOCKER_GEN_CONTAINER}" "/etc/docker-gen/templates/${TEMPLATE}"
