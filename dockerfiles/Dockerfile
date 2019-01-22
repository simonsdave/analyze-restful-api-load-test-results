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
FROM ubuntu:16.04

MAINTAINER Dave Simons

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
# this list came from https://hub.docker.com/r/aaron465/matplotlib/dockerfile
RUN apt-get install -y python python-dev python-pip libxft-dev libfreetype6 libfreetype6-dev
RUN pip install --upgrade pip

COPY analyze-restful-api-load-test-results.tar.gz /tmp/analyze-restful-api-load-test-results.tar.gz
RUN pip install /tmp/analyze-restful-api-load-test-results.tar.gz
RUN rm /tmp/analyze-restful-api-load-test-results.tar.gz

# as per http://stackoverflow.com/questions/29073802/matplotlib-cannot-find-configuration-file-matplotlibrc
RUN mkdir -p /root/.config/matplotlib
ADD matplotlibrc /root/.config/matplotlib/matplotlibrc
RUN chown --recursive root:root /root/.config

RUN mkdir -p /graphs

ENV DEBIAN_FRONTEND newt
