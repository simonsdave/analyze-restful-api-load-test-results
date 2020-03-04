#!/usr/bin/env bash

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

test_analyze_no_graphs() {
    STDOUT=${1:-}
    shift

    docker container run \
        --rm \
        -i \
        "${DOCKER_IMAGE}" \
        analyze-restful-api-load-test-results.sh \
        < "${SCRIPT_DIR_NAME}/data/happy-path-stdin.tsv" \
        > "${STDOUT}"
    RETURN_VALUE=$?

    if ! diff "${STDOUT}" "${SCRIPT_DIR_NAME}/data/happy-path-stdout.txt"; then
        RETURN_VALUE=1
    fi

    return ${RETURN_VALUE}
}

test_analyze_with_graphs() {
    STDOUT=${1:-}
    shift

    GRAPHS_CONTAINER_NAME=$(openssl rand -hex 16)

    docker container run \
        "--name=${GRAPHS_CONTAINER_NAME}" \
        -i \
        "${DOCKER_IMAGE}" \
        analyze-restful-api-load-test-results.sh \
        "--graphs=/tmp/graphs.pdf" \
        < "${SCRIPT_DIR_NAME}/data/happy-path-stdin.tsv" \
        > "${STDOUT}"
    RETURN_VALUE=$?

    if ! diff "${STDOUT}" "${SCRIPT_DIR_NAME}/data/happy-path-stdout.txt"; then
        RETURN_VALUE=1
    fi

    docker container cp "${GRAPHS_CONTAINER_NAME}:/tmp/graphs.pdf" "${SCRIPT_DIR_NAME}/graph.pdf"
    # :QUESTION: is there a way to validate that graph.pdf is a valid pdf doc
    rm "${SCRIPT_DIR_NAME}/graph.pdf"

    # :TRICKY: implict check that pdf was created - rm will fail
    # and thus this script will fail if the pdf isn't created
    # :TODO: how do we know the graph is a pdf and accurate?
    rm -f "${GRAPH}"

    return ${RETURN_VALUE}
}

test_steep_slope() {
    STDOUT=${1:-}
    shift

    docker container run \
        --rm \
        -i \
        "${DOCKER_IMAGE}" \
        analyze-restful-api-load-test-results.sh \
        < "${SCRIPT_DIR_NAME}/data/steep-slope-stdin.tsv" \
        > "${STDOUT}"
    if [[ $? == 1 ]]; then
        RETURN_VALUE=0
    else
        RETURN_VALUE=1
    fi

    if ! diff "${STDOUT}" "${SCRIPT_DIR_NAME}/data/steep-slope-stdout.txt"; then
        RETURN_VALUE=1
    fi

    return ${RETURN_VALUE}
}

test_bad_input() {
    STDOUT=${1:-}
    shift

    docker container run \
        --rm \
        -i \
        "${DOCKER_IMAGE}" \
        analyze-restful-api-load-test-results.sh \
        < "${SCRIPT_DIR_NAME}/data/bad-stdin.tsv" \
        > "${STDOUT}"
    RETURN_VALUE=$?

    if ! diff "${STDOUT}" "${SCRIPT_DIR_NAME}/data/bad-stdout.txt"; then
        RETURN_VALUE=1
    fi

    return ${RETURN_VALUE}
}

test_wrapper() {
    TEST_FUNCTION_NAME=${1:-}
    shift

    # :ODD: Normally you'd expect the line below to be something like
    # "STDOUT=$(mktemp)" but when that was used the error "The path /var/<something>
    # is not shared from OS X and is not known to Docker" was generated
    # and could not figure out what the problem and hence the current
    # implementation.
    STDOUT=${SCRIPT_DIR_NAME}/stdout.txt

    NUMBER_TESTS_RUN=$((NUMBER_TESTS_RUN+1))
    echo -n "."
    if "${TEST_FUNCTION_NAME}" "${STDOUT}" "$@"; then
        NUMBER_TEST_SUCCESSES=$((NUMBER_TEST_SUCCESSES+1))
    else
        NUMBER_TEST_FAILURES=$((NUMBER_TEST_FAILURES+1))

        echo ""
        echo "${TEST_FUNCTION_NAME} failed - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        cat "${STDOUT}"
        echo "${TEST_FUNCTION_NAME} failed - <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    fi

    rm -f "${STDOUT}"
}

if [ $# != 1 ]; then
    echo "usage: $(basename "$0") <docker image>" >&2
    exit 1
fi

DOCKER_IMAGE=${1:-}

#
# test_wrapper function will update these environment variables
# so we can generate a reasonable status message after running
# all the integration tests
#
NUMBER_TESTS_RUN=0
NUMBER_TEST_SUCCESSES=0
NUMBER_TEST_FAILURES=0

#
# all the setup is done - time to run some tests!
#
test_wrapper test_analyze_no_graphs
test_wrapper test_analyze_with_graphs
test_wrapper test_steep_slope
test_wrapper test_bad_input

#
# all the tests are complete - generate a reasonable status message
#
echo ""
echo "Ran ${NUMBER_TESTS_RUN} integration tests. ${NUMBER_TEST_SUCCESSES} successes. ${NUMBER_TEST_FAILURES} failures."

#
# and we're done:-)
#
if [[ "${NUMBER_TEST_FAILURES}" != "0" ]]; then
    exit 1
fi

exit 0
exit 0
