#!/usr/bin/env bash
#
# The run a load test analyze_load_test_tsv.py is launched. However, callers
# should not run analyze_load_test_tsv.py directly because
# you'll generate a harmless but unsettling warning message.
#

set -e

SCRIPT_DIR_NAME="$( cd "$( dirname "$0" )" && pwd )"

VERBOSE=0
GRAPHS_FILENAME=/dev/null
MAX_SLOPE=0.10

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
            GRAPHS_FILENAME=$1
            shift
            ;;
        -m|--max-slope)
            shift
            MAX_SLOPE=$1
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ $# != 0 ]; then
    echo "usage: `basename $0` [-v -g <graphs filename> -m <max slope>]" >&2
    exit 1
fi

# as per https://github.com/matplotlib/matplotlib/issues/5836#issuecomment-212052820
# running the 'python -c ...' to eliminate the message
#
#   Matplotlib is building the font cache using fc-list.
#
# when analyze-restful-api-load-test-results.py runs
python -c 'import matplotlib.pyplot' >& /dev/null

analyze_restful_api_load_test_results.py --max-slope=$MAX_SLOPE --graphs="$GRAPHS_FILENAME"

exit $?
