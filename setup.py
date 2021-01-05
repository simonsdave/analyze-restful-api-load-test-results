#
# to build the distrubution @ dist/analyze_restful_api_load_test_results-*.*.*.tar.gz
#
#   >git clone git@github.com:simonsdave/analyze-restful-api-load-test-results.git
#   >cd analyze-restful-api-load-test-results
#   >python setup.py bdist_wheel sdist --formats=gztar
#

import re

from setuptools import setup

#
# this approach used below to determine ```version``` was inspired by
# https://github.com/kennethreitz/requests/blob/master/setup.py#L31
#
# why this complexity? wanted version number to be available in the
# a runtime.
#
# the code below assumes the distribution is being built with the
# current directory being the directory in which setup.py is stored
# which should be totally fine 99.9% of the time. not going to add
# the coode complexity to deal with other scenarios
#
reg_ex_pattern = r'__version__\s*=\s*[\'"](?P<version>[^\'"]*)[\'"]'
reg_ex = re.compile(reg_ex_pattern)
version = ''
with open('analyze_restful_api_load_test_results/__init__.py', 'r') as fd:
    for line in fd:
        match = reg_ex.match(line)
        if match:
            version = match.group('version')
            break
if not version:
    raise Exception('Cannot locate project version number')

setup(
    name='analyze_restful_api_load_test_results',
    packages=[
        'analyze_restful_api_load_test_results',
    ],
    scripts=[
        'bin/analyze-restful-api-load-test-results.py',
        'bin/analyze-restful-api-load-test-results.sh',
    ],
    install_requires=[
        'matplotlib==3.3.3',
        'numpy==1.19.5',
        'python-dateutil>=2.8,<2.9',
    ],
    include_package_data=True,
    version=version,
    description='Analyze RESTful API Load Test Results',
    author='Dave Simons',
    author_email='simonsdave@gmail.com',
    url='https://github.com/simonsdave/analyze-restful-api-load-test-results',
    # list of valid classifiers @ https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'Natural Language :: English',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: Implementation :: CPython',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
)
