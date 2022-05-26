# MyConfig

## link
```bash
$ cd dotfiles  && ./script/setup.sh
```

## vim
- plugin
	- `dein_install.sh`でdeinをインストール
	- vim で `:call dein#install()`を実行
- lsp
	- coc.nvim(\<v8.2) → nodejs, yarn
	- ddc.vim(\>=v8.2) → deno

## wezterm
- デフォルトの端末に設定(Ubuntu)
	```
	$ sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which wezterm` 30
	$ sudo update-alternatives --config x-terminal-emulator
	```

## DE
- i3 (i3wm or i3-gap)
- compton (picom)
- ~~imagemagick~~ → maim
- feh pasystray ffmpeg nm-applet

