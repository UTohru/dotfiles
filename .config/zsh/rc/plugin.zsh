
if [ -x "$(command -v cargo)" ]; then
	if [ ! -x "$(command -v sheldon)" ]; then
		cargo install sheldon
	fi
	if [ ! -x "$(command -v zoxide)" ]; then
		cargo install zoxide
	fi
	eval "$(zoxide init zsh)"
	eval "$(sheldon source)"
fi

