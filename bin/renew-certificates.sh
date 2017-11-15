#!/usr/bin/env bash

LETSENCRYPT=${LETSENCRYPT:-"letsencrypt"}
command -v "${LETSENCRYPT}" >/dev/null 2>&1 || { echo >&2 "Let's Encrypt client \"${LETSENCRYPT}\" not installed. Aborting!"; exit 1; }
"${LETSENCRYPT}" renew
