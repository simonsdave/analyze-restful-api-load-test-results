#!/usr/bin/env bash

set -e

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

test_analyze_no_graphs() {
    DOCKER_IMAGE=${1:-}

    docker run \
        --rm \
        -i \
        "$DOCKER_IMAGE" \
        analyze_restful_api_load_test_results.sh \
        < "$SCRIPT_DIR_NAME/stdin/happy_path.tsv"
}

test_analyze_with_graphs() {
    DOCKER_IMAGE=${1:-}

    GRAPH=$(mktemp)

    docker run \
        --rm \
        -i \
        -v "$(dirname "$GRAPH"):/graphs" \
        "$DOCKER_IMAGE" \
        analyze_restful_api_load_test_results.sh \
        "--graphs=/graphs/$(basename "$GRAPH")" \
        < "$SCRIPT_DIR_NAME/stdin/happy_path.tsv"

    # :TRICKY" implict check that pdf was created - rm will fail
    # and thus this script will fail if the pdf isn't created
    rm "$GRAPH"
}

if [ $# != 1 ]; then
    echo "usage: $(basename "$0") <docker image>" >&2
    exit 1
fi

DOCKER_IMAGE=${1:-}

test_analyze_no_graphs "$DOCKER_IMAGE"
test_analyze_with_graphs "$DOCKER_IMAGE"

exit 0
