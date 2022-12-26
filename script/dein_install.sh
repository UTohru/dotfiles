#!/bin/sh


# dein -> https://github.com/Shougo/dein.vim
if [ ! -d ~/.vim/dein ]; then
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/installer.sh > installer.sh
	chmod u+x ./installer.sh
	./installer.sh ~/.vim/dein
	rm installer.sh
fi


