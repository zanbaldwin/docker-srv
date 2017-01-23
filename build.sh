#!/bin/bash

# Use this if you wish to prefix the image name with something.
# E.g. "registry.gitlab.com/" to result in images like "registry.gitlab.com/vendor/image:tag".
IMAGE_PREFIX=${IMAGE_PREFIX:-}

DOCKER=$(which docker)
if [ $? -ne 0 ]; then
    echo "Docker not installed."
    exit 1
fi

INFO=$($DOCKER info)
if [ $? -ne 0 ]; then
    echo "Docker not accessible. Try rerunning this script as root."
    exit 2
fi

# Get full, resolved directory of the currect script.
SOURCE="${BASH_SOURCE[0]}"
# Resolve $SOURCE until the file is no longer a symlink.
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    # If $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located.
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Determine if the build script is part of a Git repository, and determine the appropriate tag to use for the image.
IMAGE_TAG="latest"
GIT=$(which git)
if [ $? -eq 0 ]; then
    # Git is installed. Great start.
    GITDIR=$(cd $DIR; $GIT rev-parse --git-dir 2>/dev/null)
    if [ "$GITDIR" != "" ]; then
        # The directory that the current script is located in is a Git repository, grab the latest short tag.
        IMAGE_TAG=$(cd $DIR; $GIT describe --tags --abbrev=0)
    fi
fi

for PATH in $DIR/images/*; do
    IMAGE=(${PATH//\// })
    IMAGE=${IMAGE[${#IMAGE[@]}-1]}
    IMAGE_NAME="${IMAGE_PREFIX}darsyn/${IMAGE}:${IMAGE_TAG}"
    $DOCKER build -t "$IMAGE_NAME" $PATH
    if [ $? -ne 0 ]; then
        echo ""
        echo "Error building '$IMAGE_NAME'."
        exit 1
    fi
done
