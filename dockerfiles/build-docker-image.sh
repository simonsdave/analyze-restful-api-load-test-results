#!/usr/bin/env bash

set -e

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

if [ $# != 2 ]; then
    echo "usage: $(basename "$0") <package> <image-name>" >&2
    exit 1
fi

PACKAGE=${1:-}
IMAGE_NAME=${2:-}

CONTEXT_DIR=$(mktemp -d 2> /dev/null || mktemp -d -t DAS)

cp "${PACKAGE}" "${CONTEXT_DIR}/package.tar.gz"
cp "${SCRIPT_DIR_NAME}/matplotlibrc" "${CONTEXT_DIR}/."
docker build -t "${IMAGE_NAME}" --file "${SCRIPT_DIR_NAME}/Dockerfile" "${CONTEXT_DIR}"

rm -rf "${CONTEXT_DIR}"

exit 0
