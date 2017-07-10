#!/usr/bin/env bash
#
# The run a load test analyze_load_test_tsv.py is launched. However, callers
# should not run analyze_load_test_tsv.py directly because:
#
#   1/ you'll generate a harmless but unsettling warning message
#   2/ you'll struggle to get the redirection right
#
# This script eliminates the above problems. To run
# analyze-restful-api-load-test-results.sh you'll want
# to do something like this:
#
#   docker run \
#       -i \
#       -v $PWD:/graphs \
#       simonsdave/analyze-restful-api-load-test-results \
#       analyze_restful_api_load_test_results.sh \
#       --verbose \
#       --graphs mygraphs.pdf
#       < k6-output.tsv
#

set -e

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

VERBOSE=0
GRAPHS_PDF_FILE_NAME=restful-api-load-test-results-graphs.pdf

while true
do
    OPTION=`echo ${1:-} | awk '{print tolower($0)}'`
    case "$OPTION" in
        -v|--verbose)
            shift
            VERBOSE=1
            ;;
        -g|--graphs)
            shift
            GRAPHS_PDF_FILE_NAME=$1
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ $# != 0 ]; then
    echo "usage: `basename $0` [-v -g <graphs filename>]" >&2
    exit 1
fi

# as per https://github.com/matplotlib/matplotlib/issues/5836#issuecomment-212052820
# running the 'python -c ...' to eliminate the message
#
#   Matplotlib is building the font cache using fc-list.
#
# when analyze-restful-api-load-test-results.py runs
python -c 'import matplotlib.pyplot' >& /dev/null

analyze_restful_api_load_test_results.py --graphs=/graphs/$GRAPHS_PDF_FILE_NAME

exit 0
