# to build the image
#
#   docker build -t simonsdave/analyze-restful-api-load-test-results .
#
# to run just the numerical analysis
#
#   docker run -i simonsdave/analyze-restful-api-load-test-results analyze_restful_api_load_test_results.sh < input.tsv
#
# to run just the numerical and graphical analysis
#
#   docker run -i -v $PWD:/graphs simonsdave/analyze-restful-api-load-test-results analyze_restful_api_load_test_results.sh --graphs=/graphs/mygraphs.pdf < input.tsv
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

ENV DEBIAN_FRONTEND noninteractive

# the apt-get of "build-dep matplotlib" is as per
# http://blog.pangyanhan.com/posts/2015-07-25-how-to-install-matplotlib-using-virtualenv-on-ubuntu.html

# the somewhat cryptic chaining of apt-get commands is
# in there based on advice described in
# http://blog.replicated.com/refactoring-a-dockerfile-for-image-size/

COPY analyze-restful-api-load-test-results.tar.gz /tmp/analyze-restful-api-load-test-results.tar.gz

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends python python-dev python-pip libxft-dev libfreetype6 libfreetype6-dev libffi-dev && \
    apt-get -y build-dep matplotlib && \
    pip install /tmp/analyze-restful-api-load-test-results.tar.gz && \
    rm /tmp/analyze-restful-api-load-test-results.tar.gz && \
    apt-get remove -y python-pip curl && \
    rm -rf /var/lib/apt/lists/*

# as per http://stackoverflow.com/questions/29073802/matplotlib-cannot-find-configuration-file-matplotlibrc
RUN mkdir -p /root/.config/matplotlib
ADD matplotlibrc /root/.config/matplotlib/matplotlibrc
RUN chown --recursive root:root /root/.config

RUN mkdir -p /graphs

ENV DEBIAN_FRONTEND newt
