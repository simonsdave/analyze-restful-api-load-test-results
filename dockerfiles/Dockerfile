FROM ubuntu:18.04

MAINTAINER Dave Simons

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y

#
# python 3 development
# -- inspired by https://websiteforstudents.com/installing-the-latest-python-3-7-on-ubuntu-16-04-18-04/
# -- python versions @ https://www.python.org/downloads/
# -- pip3 inspired by https://linuxize.com/post/how-to-install-pip-on-ubuntu-18.04/
#
RUN apt-get install -y software-properties-common
RUN apt-get install --reinstall ca-certificates
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update -y
RUN apt-get install -y python3.7
RUN apt-get install -y python3-dev
RUN apt-get install -y python3-pip
RUN python3.7 -m pip install --upgrade pip

COPY package.tar.gz /tmp/package.tar.gz
RUN python3.7 -m pip install /tmp/package.tar.gz
RUN rm /tmp/package.tar.gz

# as per http://stackoverflow.com/questions/29073802/matplotlib-cannot-find-configuration-file-matplotlibrc
RUN mkdir -p /root/.config/matplotlib
ADD matplotlibrc /root/.config/matplotlib/matplotlibrc
RUN chown --recursive root:root /root/.config

RUN mkdir -p /graphs

ENV DEBIAN_FRONTEND newt
