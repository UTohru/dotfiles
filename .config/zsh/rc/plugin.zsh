
# if [ -x "$(command -v sheldon)" ]; then
# 	eval "$(sheldon source)"
# fi

if [ -x "$(command -v zoxide)" ]; then
	eval "$(zoxide init zsh)"
fi
