#!/usr/bin/env bash
#
# This script builds analyze-restful-api-load-test-results docker image
#

set -e

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

if [ $# != 3 ]; then
    echo "usage: $(basename "$0") <username> <tag> <analyze-tar-gz>" >&2
    exit 1
fi

USERNAME=${1:-}
TAG=${2:-}
ANALYZE_TAR_GZ=${3:-}

IMAGENAME=${USERNAME}/analyze-restful-api-load-test-results:${TAG}

cp "${ANALYZE_TAR_GZ}" "${SCRIPT_DIR_NAME}/analyze-restful-api-load-test-results.tar.gz"
docker build -t "${IMAGENAME}" "${SCRIPT_DIR_NAME}"
rm "${SCRIPT_DIR_NAME}/analyze-restful-api-load-test-results.tar.gz"

exit 0
