#!/bin/bash

SRC_DIR="/usr/src"
#PYTHON_DIR="$HOME/.pyenv/shims/python"

cd ${SRC_DIR}

if [ ! -d ${SRC_DIR}/vim ]; then
	git clone https://github.com/vim/vim
fi
cd vim/src

CONFIG=()
CONFIG+=("with-features=huge")
CONFIG+=("enable-multibyte")
#CONFIG+=("enable-acl")
CONFIG+=("enable-terminal")
CONFIG+=("enable-fontset")
CONFIG+=("enable-python3interp")


#./configure \
#	--with-features=huge \
#	--enable-multibyte \
#	--enable-cscope \
#	--enable-acl \
#	--enable-terminal \
#	--enable-fontset \
#	--enable-python3interp \
#	vi_cv_path_python3=${PYTHON_DIR}
#make

CMD="./configure"
for v in "${CONFIG[@]}"
do
	CMD+=" --${v}"
done

make distclean
eval ${CMD}
make


./vim --version

echo "pls check and make install"
# terminalやメッセージの日本語化，py3 print(sys.version)などを試す

# make install

