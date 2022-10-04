
# setup
## sym link
```bash
$ cd dotfiles  && ./script/setup.sh
```
## font install
```
$ ./script/font_install.sh
```

## vim plugin install
1. dein(plugin manager) install
	```
	dein_install.sh
	```
1. deno install
	```
	$ curl -fsSL https://deno.land/install.sh | sh
	```
	(if vim version is under 8.2 use nodejs,yarn instead)
1. plugin install
	```
	# in vim
	:call dein#install() 
	```

## term
1. terminal install
1. set x-terminal-emulator 
	- default
		```
		$ ln -s `which <term-name>` ~/.local/bin/x-terminal-emulator
		```
	- Debian
		```
		$ sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which <term-name>` 30
		$ sudo update-alternatives --config x-terminal-emulator
		```


