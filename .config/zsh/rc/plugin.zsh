
if [ -x "$(command -v cargo)" ]; then
	if [ ! -x "$(command -v sheldon)" ]; then
		cargo install sheldon
	fi
	eval "$(sheldon source)"
fi

