
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
1. dein(plugin manager)
	```
	dein_install.sh
	```
1. deno install
	```
	`$ curl -fsSL https://deno.land/install.sh | sh`
	```
	(v8.2↓ -> nodejs, yarn)
1. plugin install
	```
	# in vim
	:call dein#install() 
	```

## term
1. terminal install
1. ``ln -s `which <term-name>` ~/.local/bin/x-terminal-emulator``
	- case of Ubuntu
		```
		$ sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which <term-name>` 30
		$ sudo update-alternatives --config x-terminal-emulator
		```

___

## DE memo
- i3 (i3wm or i3-gap)
- compton (picom)
- ~~imagemagick~~ → maim
- feh pasystray ffmpeg nm-applet

