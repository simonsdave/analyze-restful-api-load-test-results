#!/usr/bin/env bash

set -e

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

test_analyze_no_graphs() {
    DOCKER_IMAGE=${1:-}

    STDOUT=$(mktemp)

    docker run \
        --rm \
        -i \
        "$DOCKER_IMAGE" \
        analyze_restful_api_load_test_results.sh \
        < "$SCRIPT_DIR_NAME/data/happy_path_stdin.tsv" \
        > "$STDOUT"

    diff "$STDOUT" "$SCRIPT_DIR_NAME/data/happy_path_stdout.txt"

    rm "$STDOUT"
}

test_analyze_with_graphs() {
    DOCKER_IMAGE=${1:-}

    STDOUT=$(mktemp)
    GRAPH=$(mktemp)

    docker run \
        --rm \
        -i \
        -v "$(dirname "$GRAPH"):/graphs" \
        "$DOCKER_IMAGE" \
        analyze_restful_api_load_test_results.sh \
        "--graphs=/graphs/$(basename "$GRAPH")" \
        < "$SCRIPT_DIR_NAME/data/happy_path_stdin.tsv" \
        > "$STDOUT"

    diff "$STDOUT" "$SCRIPT_DIR_NAME/data/happy_path_stdout.txt"

    # :TRICKY" implict check that pdf was created - rm will fail
    # and thus this script will fail if the pdf isn't created
    # :TODO: how do we know the graph is a pdf and accurate?
    rm "$GRAPH"

    rm "$STDOUT"
}

if [ $# != 1 ]; then
    echo "usage: $(basename "$0") <docker image>" >&2
    exit 1
fi

DOCKER_IMAGE=${1:-}

test_analyze_no_graphs "$DOCKER_IMAGE"
test_analyze_with_graphs "$DOCKER_IMAGE"

exit 0
