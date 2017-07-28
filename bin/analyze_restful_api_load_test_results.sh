#!/usr/bin/env bash
#
# analyze_restful_api_load_test_results.py does the real analysis
# and if you launch it directly you'll generate a harmless but
# unsettling warning message. the single purpose of this shell
# script is to eliminate the warning message.
#
# all arguments to this shell script are passed directly and
# unmodified to analyze_restful_api_load_test_results.py.
#
# analyze_restful_api_load_test_results.py is this script's
# exit code.
#

#
# as per https://github.com/matplotlib/matplotlib/issues/5836#issuecomment-212052820
# running the 'python -c ...' to eliminate the message
#
#   Matplotlib is building the font cache using fc-list.
#
# when analyze-restful-api-load-test-results.py runs
#
python -c 'import matplotlib.pyplot' >& /dev/null

analyze_restful_api_load_test_results.py "$@"

exit $?
