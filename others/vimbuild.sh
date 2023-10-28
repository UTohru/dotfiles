#!/usr/bin/env bash

# 1. install asdf or pyenv, and python dependencies.
# 2. install gettext (for localization)
# 3. use this script

#SRC_DIR="/usr/src"
SRC_DIR="$HOME/src/"

if [ ! -d "${SRC_DIR}/vim" ]; then
	mkdir -p $SRC_DIR
fi
cd ${SRC_DIR}


if [ ! -d ${SRC_DIR}/vim ]; then
	git clone --depth=1 https://github.com/vim/vim
	cd vim/src
else
	cd vim
	git pull
	cd src
fi


# Python
CONFIGURE_OPTS="--enable-shared" \
echo "Installing $PYTHON3 ..."
if builtin command -V asdf > /dev/null 2>&1; then
	PYTHON3=$(asdf latest python)
	asdf install python $PYTHON3

	PREFIX="${HOME}/.asdf/installs/python"
	asdf local python ${PYTHON3}
elif builtin command -V pyenv > /dev/null 2>&1; then
	PYTHON3=$(pyenv install -l | \
		grep -E "^  3\.[0-9]+\.[0-9]+$" | \
		tail -1 | sed -e 's/^[ ]*//')
	pyenv install $PYTHON3

	PREFIX="${HOME}/.pyenv/versions"
	pyenv local ${PYTHON3}
else
	echo "Error: Python virtual runtime not found"
	exit 1
fi

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
./vim --version
make install

