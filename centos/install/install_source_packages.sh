#!/usr/bin/env bash
#
# Shell script to install all needed development tools and software
# Run as root/sudo
#

# Colors for printing
RED='\033[1;31m'
BLU='\033[1;34m'
NC='\033[0m'

# Path to temporary installation directory
insPath=/tmp/auto_sys_install/

# Simple error handler function to print to stderr
err() {
  echo -e "${RED}[$(date +"%T")] ERROR:${NC} $@" >&2
  exit 1
}

# Simple message handler function
msg() {
  echo -e "\n${BLU}[$(date +"%T")]:${NC} $@\n"
}

if [[ $1 = "-h" ]]; then
  echo "Usage: ./install_packages [-a]"
  echo -e "\t-a,\tInstall all packages including source based ones that may be redundant"
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  err "This script must be run as root, exiting!"
fi

pkgApp=yum
msg "Using $pkgApp pakage manager for installation"

msg "Install started at: $(date)"
msg "Creating temp directory at: $insPath\n"
mkdir -p $insPath
pushd $insPath

###############################################################################
# Source-based installs
###############################################################################

# GHDL- FOSS VHDL compiler & simulator
msg "Installing GHDL from source..."
git clone https://github.com/ghdl/ghdl.git
mkdir ./ghdl/build
pushd ./ghdl/build
../configure --with-llvm-config --prefix=/usr/local
make && make install
popd

## TODO: verify for distros other than fedora
# Go- remove older Go 1st (if there) then install (note DL link should be
# checked for updates)
#msg "Installing Go from source..."
#rm -rf /usr/local/go
#TODO: figure out per system install from https://golang.org/doc/install
#wget https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz
#tar -C /usr/local/ -xzf go1.9.linux-amd64.tar.gz

# Rust install
msg "Installing Rust from source..."
curl https://sh.rustup.rs -sSf | sh

# tmux 2.9a install from src
msg "Installing tmux from source..."
wget https://github.com/tmux/tmux/releases/download/2.9a/tmux-2.9a.tar.gz
tar -xzf tmux-2.9a.tar.gz
pushd tmux-2.9a
./configure && make
make install
popd

# Vim install from src w/clipboard & python support
msg "Installing Vim from source..."
# NOTE: remove shipping Vim
yum remove vim-enhanced vim-common vim-minimal
yum-builddep vim

git clone https://github.com/vim/vim.git
pushd vim
./configure --with-features=huge \
  --enable-multibyte \
  --enable-rubyinterp=yes \
  --enable-pythoninterp=yes \
  --enable-perlinterp=yes \
  --enable-gui=auto \
  --enable-gtk2-check \
  --with-x
# if weird, run this process as regular user then run `make install` as sudo
# If installing for single user (no `make install`) VIMRUNTIMEDIR can == {vim_src}/runtime
make VIMRUNTIMEDIR=/usr/local/share/vim/vim80
# if installing manually, this is the only command needing root privileges
make install
# sometimes `sudo` is removed with vim
yum install -y sudo
hash vim
popd

wget http://nongnu.org/ranger/ranger-stable.tar.gz
tar xvf ranger-stable.tar.gz
pushd ranger-stable
make install
popd

#TODO: add custom Google Fonts from www.fonts.google.com for some distros

###############################################################################
# Clean & exit
###############################################################################

msg "Deleting temp directory at $insPath"
popd
rm -rf $insPath*
msg "\nDONE!... Installs and updates successful\n"

