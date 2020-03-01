#!/usr/bin/env python

import sys

from analyze_restful_api_load_test_results import CommandLineParser
from analyze_restful_api_load_test_results import Main


if __name__ == '__main__':
    clp = CommandLineParser()
    (clo, cla) = clp.parse_args()

    main = Main()
    main.load_data()
    exit_code = main.numerical_analysis(clo.max_slope)
    main.generate_graphs(clo.graphs)
    sys.exit(exit_code)
