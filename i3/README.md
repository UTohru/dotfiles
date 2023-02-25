
## i3 config
Initially, the C-d launcher can be used

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
