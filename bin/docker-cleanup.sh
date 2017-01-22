#!/bin/bash

DOCKER=$(which docker)
if [ $? -ne 0 ]; then
    echo "Docker not installed."
    exit 1
fi

INFO=$($DOCKER info 1>/dev/null 2>&1)
if [ $? -ne 0 ]; then
    echo "Docker not available."
    exit 1
fi

$DOCKER rm $($DOCKER ps --all -q -f status=exited)
