#!/usr/bin/env bash

#
# this script provisions a analyze-restful-api-load-test-results development environment
#

set -e

#
# install matplotlib
#
apt-get update -y
apt-get install -y \
    python-virtualenv \
    python \
    python-dev \
    python-pip \
    libxft-dev \
    libfreetype6 \
    libfreetype6-dev \
    libffi-dev

# as per http://blog.pangyanhan.com/posts/2015-07-25-how-to-install-matplotlib-using-virtualenv-on-ubuntu.html
apt-get -y build-dep matplotlib

su vagrant <<'EOF'
mkdir -p ~/.config/matplotlib

echo '# see http://matplotlib.org/users/customizing.html#the-matplotlibrc-file' > ~/.config/matplotlib/matplotlibrc
echo '# for general details on this file' >> ~/.config/matplotlib/matplotlibrc
echo '' >> ~/.config/matplotlib/matplotlibrc
echo '# the backend configuration option was added (the whole reason this file' >> ~/.config/matplotlib/matplotlibrc
echo '# was created actually) so that matplotlib could generate PNGs in a headless' >> ~/.config/matplotlib/matplotlibrc
echo '# Ubuntu 14.04 deployment as per the info in this article' >> ~/.config/matplotlib/matplotlibrc
echo '# http://stackoverflow.com/questions/2801882/generating-a-png-with-matplotlib-when-display-is-undefined' >> ~/.config/matplotlib/matplotlibrc
echo 'backend : Agg' >> ~/.config/matplotlib/matplotlibrc
EOF

exit 0
