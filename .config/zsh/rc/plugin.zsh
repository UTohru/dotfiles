
if [ -x "$(command -v cargo)" ]; then
	if [ ! -x "$(command -v sheldon)" ]; then
		cargo install sheldon
	fi
	eval "$(sheldon source)"
fi

if [ -x "$(command -v zoxide)" ]; then
	eval "$(zoxide init zsh)"
fi
