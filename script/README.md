# Script
- Install Script
- Script for Simplicity



## create symlink
```bash
$ ./script/setup.sh
```
## font install
```
$ ./script/font_install.sh
```

## vim plugin install
1. dein install
	```
	dein_install.sh
	```
1. deno install
	```
	$ curl -fsSL https://deno.land/x/install/install.sh | sh
	```
	(if vim version is under 8.2 use nodejs,yarn instead)
1. plugin install
	```
	:call dein#install() 
	```


## i3 config
### add config
```
$ ln -s $HOME/.config/i3/available/<file> $HOME/.config/i3/enable/
```

### term 

1. terminal install
1. set x-terminal-emulator 
	- default
		```
		$ mkdir -p ~/.local/bin
		$ ln -s `which <term-name>` ~/.local/bin/x-terminal-emulator
		```
	- Debian
		```
		$ sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which <term-name>` 30
		$ sudo update-alternatives --config x-terminal-emulator
		```
