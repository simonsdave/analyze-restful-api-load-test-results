ARG CIRCLE_CI_EXECUTOR

FROM $CIRCLE_CI_EXECUTOR

MAINTAINER Dave Simons

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
# this list came from https://hub.docker.com/r/aaron465/matplotlib/dockerfile
RUN apt-get install -y libxft-dev libfreetype6 libfreetype6-dev

RUN mkdir /tmp/package
ADD package.tar.gz /tmp/package/.

RUN cd /tmp/package && python3.9 -m pip install --requirement requirements.txt

# as per http://stackoverflow.com/questions/29073802/matplotlib-cannot-find-configuration-file-matplotlibrc
RUN mkdir -p /root/.config/matplotlib
RUN cp /tmp/package/dev_env/matplotlibrc /root/.config/matplotlib/.
RUN chown --recursive root:root /root/.config

RUN rm -rf "/tmp/package"

ENV DEBIAN_FRONTEND newt

ENV PATH "/app/bin:${PATH}"
ENV PYTHONPATH /app

WORKDIR /app
