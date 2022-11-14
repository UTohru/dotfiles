#!/bin/bash

#SRC_DIR="/usr/src"
SRC_DIR="$HOME/src/"

if [ ! -d ${SRC_DIR}/vim ]; then
	mkdir -p $SRC_DIR
fi
cd ${SRC_DIR}


if [ ! -d ${SRC_DIR}/vim ]; then
	git clone --depth=1 https://github.com/vim/vim
fi
cd vim/src


PYTHON3=$(pyenv install -l | \
    grep -E "^  3\.[0-9]+\.[0-9]+$" | \
    tail -1 | sed -e 's/^[ ]*//')

echo "Installing $PYTHON3 ..."

CONFIGURE_OPTS="--enable-shared" \
    pyenv install $PYTHON3
PREFIX="${HOME}/.pyenv/versions"

pyenv local ${PYTHON3}

make distclean
LDFLAGS="-Wl,-rpath=${PREFIX}/${PYTHON3}/lib" ./configure \
	--with-features=huge \
	--enable-multibyte \
	--enable-acl \
	--enable-terminal \
	--enable-fontset \
	--enable-python3interp=dynamic \
	--prefix=${HOME}/.local/
make

# CONFIG=()
# CONFIG+=("with-features=huge")
# CONFIG+=("enable-multibyte")
# #CONFIG+=("enable-acl")
# CONFIG+=("enable-terminal")
# CONFIG+=("enable-fontset")
# CONFIG+=("enable-python3interp")
# CONFIG+=("prefix=$HOME/.local/")
# CMD="./configure"
# for v in "${CONFIG[@]}"
# do
# 	CMD+=" --${v}"
# done
# 
# eval ${CMD}

make


./vim --version

echo "pls check and make install"
# terminalやメッセージの日本語化，py3 print(sys.version)などを試す

# make install

