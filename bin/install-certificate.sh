#!/usr/bin/env bash

SCRIPT=$(basename "$0")
function display_usage() {
    echo "Usage:" 1>&2
    echo "    ${SCRIPT} <webroot> <domain>" 1>&2
    echo "" 1>&2
    echo "Arguments:" 1>&2
    echo "    webroot     The public webroot directory." 1>&2
    echo "    domain      The domain to fetch a certificate for (without www prefix)." 1>&2
    echo "" 1>&2
    echo "Description:" 1>&2
    echo "    Install a certificate from Let's Encrypt for the specified domain." 1>&2
}

if [ $# -lt 2 ]; then
    display_usage
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Webroot is not a valid directory." 1>&2
    exit 1
fi

LETSENCRYPT=${LETSENCRYPT:-"letsencrypt"}
command -v "${LETSENCRYPT}" >/dev/null 2>&1 || { echo >&2 "Let's Encrypt client \"${LETSENCRYPT}\" not installed. Aborting!"; exit 1; }
"${LETSENCRYPT}" certonly --webroot -w "$1" -d "$2" -d "www.$2"
