# to build the image
#
#   docker build -t simonsdave/analyze-restful-api-load-test-results .
#
# to run the image
#
#   docker run -i -v $PWD:/graphs simonsdave/analyze-restful-api-load-test-results analyze_restful_api_load_test_results.sh --graphs /graphs < input.tsv
#
# for testing/debugging
#
#   docker run -i -t simonsdave/analyze-restful-api-load-test-results /bin/bash
#
# to push to dockerhub
#
#   docker push simonsdave/analyze-restful-api-load-test-results
#
FROM ubuntu:14.04

MAINTAINER Dave Simons

RUN apt-get update -y && apt-get install -y python python-dev python-pip libxft-dev libfreetype6 libfreetype6-dev libffi-dev
# as per http://blog.pangyanhan.com/posts/2015-07-25-how-to-install-matplotlib-using-virtualenv-on-ubuntu.html
RUN apt-get -y build-dep matplotlib

ADD requirements.txt /tmp/requirements.txt
RUN pip install --requirement /tmp/requirements.txt
RUN rm /tmp/requirements.txt

# as per http://stackoverflow.com/questions/29073802/matplotlib-cannot-find-configuration-file-matplotlibrc
RUN mkdir -p /root/.config/matplotlib
ADD matplotlibrc /root/.config/matplotlib/matplotlibrc
RUN chown --recursive root:root /root/.config

RUN mkdir -p /graphs

ADD analyze_restful_api_load_test_results.py /usr/local/bin/analyze_restful_api_load_test_results.py
ADD analyze_restful_api_load_test_results.sh /usr/local/bin/analyze_restful_api_load_test_results.sh
