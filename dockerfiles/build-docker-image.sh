#!/usr/bin/env bash
#
# This script builds analyze-restful-api-load-test-results docker image
#

set -e

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

usage() {
    echo "usage: $(basename "$0") [-t <tag>] <username> [<password>]" >&2
    return 0
}

TAG=latest

while true
do
    case "${1,,}" in
        -h|--help)
            shift
            usage
            exit 0
            ;;
        -t)
            shift
            TAG=${1:-latest}
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ $# != 1 ] && [ $# != 2 ]; then
    usage
    exit 1
fi

USERNAME=${1:-}
PASSWORD=${2:-}

IMAGENAME=$USERNAME/analyze-restful-api-load-test-results:$TAG

cp "$SCRIPT_DIR_NAME/../requirements.txt" "$SCRIPT_DIR_NAME/."
cp "$SCRIPT_DIR_NAME/../bin/analyze_restful_api_load_test_results.sh" "$SCRIPT_DIR_NAME/."
cp "$SCRIPT_DIR_NAME/../bin/analyze_restful_api_load_test_results.py" "$SCRIPT_DIR_NAME/."

docker build -t "$IMAGENAME" "$SCRIPT_DIR_NAME"

rm "$SCRIPT_DIR_NAME/analyze_restful_api_load_test_results.py"
rm "$SCRIPT_DIR_NAME/analyze_restful_api_load_test_results.sh"
rm "$SCRIPT_DIR_NAME/requirements.txt"

if [ "$PASSWORD" != "" ]; then
    docker login --username="$USERNAME" --password="$PASSWORD"
    docker push "$IMAGENAME"
fi

exit 0
