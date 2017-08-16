#!/usr/bin/env bash

#
# this script provisions a analyze-restful-api-load-test-results development environment
#

set -e

apt-get update -y

#
# assumes we're working in EST and enable NTP synchronization.
#
timedatectl set-timezone EST
apt-get install -y ntp

#
# install and configure git
#
apt-get install -y git

# https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/18915067#18915067
# led to seeing the value of using keychain to simplify starting the ssh-agent
# :FUTURE: in the future consider "apt-get install keychain"

su - vagrant -c "git config --global user.name \"${1:-}\""
su - vagrant -c "git config --global user.email \"${2:-}\""

# so we get the "right" editor on git commit 
su vagrant <<'EOF'
echo 'export VISUAL=vim' >> ~/.profile
echo 'export EDITOR="$VISUAL"' >> ~/.profile
EOF

# per https://help.github.com/articles/connecting-to-github-with-ssh/
# config ssh access to github
su - vagrant -c "echo \"${3:-}\" | base64 --decode > ~/.ssh/id_rsa_github.pub"
su - vagrant -c "echo \"${4:-}\" | base64 --decode > ~/.ssh/id_rsa_github"
su - vagrant -c "chmod u=r,og= ~/.ssh/id_rsa_github ~/.ssh/id_rsa_github.pub"

su vagrant <<'EOF'
echo 'export VISUAL=vim' >> ~/.profile
echo 'export EDITOR="$VISUAL"' >> ~/.profile
EOF

#
# customize vim
#
su vagrant <<'EOF'
echo 'set ruler' > ~/.vimrc
echo 'set hlsearch' >> ~/.vimrc
echo 'filetype plugin on' >> ~/.vimrc
echo 'filetype indent on' >> ~/.vimrc
echo 'set ts=4' >> ~/.vimrc
echo 'set sw=4' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'set encoding=UTF8' >> ~/.vimrc
echo 'colorscheme koehler' >> ~/.vimrc
echo 'syntax on' >> ~/.vimrc

echo 'au BufNewFile,BufRead *.sh set filetype=shell' >> ~/.vimrc
echo 'autocmd Filetype shell setlocal expandtab tabstop=4 shiftwidth=4' >> ~/.vimrc

echo 'au BufNewFile,BufRead *.json set filetype=json' >> ~/.vimrc
echo 'autocmd FileType json setlocal expandtab tabstop=4 shiftwidth=4' >> ~/.vimrc

echo 'au BufNewFile,BufRead *.py set filetype=python' >> ~/.vimrc
echo 'autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4' >> ~/.vimrc

echo 'au BufNewFile,BufRead *.raml set filetype=raml' >> ~/.vimrc
echo 'autocmd FileType raml setlocal expandtab tabstop=2 shiftwidth=2' >> ~/.vimrc

echo 'au BufNewFile,BufRead *.yaml set filetype=yaml' >> ~/.vimrc
echo 'autocmd FileType yaml setlocal expandtab tabstop=2 shiftwidth=2' >> ~/.vimrc

echo 'au BufNewFile,BufRead *.js set filetype=javascript' >> ~/.vimrc
echo 'autocmd FileType javascript setlocal expandtab tabstop=2 shiftwidth=2' >> ~/.vimrc

# install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
sed -i '1s|^|execute pathogen#infect()\n|' ~/.vimrc
EOF

#
# install docker
#
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine
usermod -aG docker vagrant
service docker restart

#
# install matplotlib
#
apt-get update -y && apt-get install -y python-virtualenv python python-dev python-pip libxft-dev libfreetype6 libfreetype6-dev libffi-dev
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
