#!/bin/sh
# Dependencies:
#     Required: bash, dirname, readlink, grep, awk
#     Optional: id, git
# A workaround for Bash will hopefully be found in the future as /bin/sh is more
# widely available on *nix systems.

# Use this if you wish to prefix the image name with something.
# E.g. "registry.gitlab.com/" to result in images like
# "registry.gitlab.com/vendor/image:tag".
IMAGE_PREFIX=${IMAGE_PREFIX:-}

# If Docker is installed in a non-standard location, set it with the $DOCKER
# environment variable, eg: `DOCKER=/usr/bin/docker-client ./build.sh`
DOCKER=${DOCKER:-"docker"}
# Use the built-in shell "command" to determine executables instead of relying
# on "which". Much more versatile as you can specify alternative executables not
# on the $PATH via environmental variables.
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

# Get the full, resolved directory of the current script NOT the current working
# directory. The following relies on dirname and readlink executables being
# available on the path, but at least this solution isn't restricted to
# Bash-only environments.
DIR=$(dirname "$(readlink -f "$0")")

# Determine if the build script is part of a Git repository, and determine the appropriate tag to use for the image.
IMAGE_TAG="latest"
GIT=$(command -v git)
if [ $? -eq 0 ]; then
    # Git is installed. Great start.
    GITDIR=$(cd "${DIR}" || return; "${GIT}" rev-parse --git-dir 2>/dev/null)
    if [ "${GITDIR}" != "" ]; then
        # The directory that the current script is located in is a Git repository, grab the latest short tag.
        IMAGE_TAG=$(cd "${DIR}" || return; "${GIT}" describe --tags --abbrev=0)
    fi
fi

for IMAGE_DIR in ${DIR}/images/*; do
    # Determine image metadata.
    IMAGE=$(basename "${IMAGE_DIR}")
    IMAGE_NAME="${IMAGE_PREFIX}darsyn/${IMAGE}:${IMAGE_TAG}"
    # Pull latest parent images.
    PARENT=$(grep "^FROM\\s.\+\(\\:.\+\)\?$" "${IMAGE_DIR}/Dockerfile" 2>/dev/null | awk '{print $2}' 2>/dev/null)
    if [ "${PARENT}" != "" ]; then
        "${DOCKER}" pull "${PARENT}"
    fi
    # Build the image.
    "${DOCKER}" build -t "${IMAGE_NAME}" "${IMAGE_DIR}"
    if [ $? -ne 0 ]; then
        echo ""
        echo "Error building '${IMAGE_NAME}'."
        exit 1
    fi
done
