#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Please supply the domain name as the first argument."
    exit 1
fi

# Get the full, resolved directory of the project root NOT the current working
# directory.
DIR=$(dirname $(dirname "$(readlink -f "$0")"))

DOCKER=${DOCKER:-"docker"}
command -v "${DOCKER}" >/dev/null 2>&1 || { echo >&2 "Docker Client \"${DOCKER}\" not installed. Aborting!"; exit 1; }
# No need to resolve $DOCKER to an absolute path, since "command" has already
# determined it's an executable.

INFO=$("${DOCKER}" info 1>/dev/null 2>&1)
if [ $? -ne 0 ]; then
    echo "Docker Daemon unavailable. Aborting!"
    if [ "$(id -u 2>/dev/null)" -ne "0" ]; then
        echo "Perhaps retry as root?"
    fi
    exit 1
fi

COMPOSE=${COMPOSE:-"docker-compose"}
command -v "${COMPOSE}" >/dev/null 2>&1 || { echo >&2 "Docker Compose \"${COMPOSE}\" not installed on \$PATH. Aborting!"; exit 1; }

OVERRIDE="${DIR}/docker-compose.override.yml"
if ! [ -f "${OVERRIDE}" ]; then
    touch "${OVERRIDE}"
    (
        echo "version: '2'";
        echo "services:";
        echo "";
    ) > "${OVERRIDE}"
fi

DOMAIN="$1" envsubst < templates/docker-compose-override.yml >> "${OVERRIDE}"
