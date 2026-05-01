#!/bin/bash
set -e

cdir="$(realpath "$(dirname "$0")")"

# ===============
# ignore localconf
# ===============
ignore_list=("${cdir}/.config/zsh/localconf/rc.zsh" "${cdir}/.config/zsh/localconf/profile.zsh" "${cdir}/.config/i3/enable/local.conf" "${cdir}/.config/sway/enable/local.conf" "${cdir}/.config/hypr/local.conf")
git update-index --skip-worktree ${ignore_list[@]}


# ===============
# vim
# ===============
if [ -x "$(command -v vim)" ]; then
	if [ -d ~/.vim ]; then
		rm -rf ~/.vim
	fi
	ln -sf ${cdir}/vim ~/.vim
	ln -sf ${cdir}/.vimrc ~/.vimrc
fi


# ===============
# config links
# ===============

function ln_config() {
	if [ ! -d ~/.config ]; then
		mkdir ~/.config
	fi
	for path in "${cdir}"/.config/*
	do
		src="$(basename "${path}")"
		if [ -d ~/.config/"${src}" ]; then
			rm -rf ~/.config/"${src}"
		fi
		ln -sf "${path}" ~/.config/"${src}"
	done
}

ln_config

if [ ! -d ${cdir}/.config/i3/wallpaper ]; then
	mkdir ${cdir}/.config/i3/wallpaper
fi

# ===============
# claude, codex, gemini, copilot
# ===============
mkdir -p ~/.claude ~/.codex ~/.gemini ~/.copilot

ln -sf "${cdir}/.config/ai-agent/AGENTS.md" ~/.claude/CLAUDE.md
ln -sf "${cdir}/.config/ai-agent/AGENTS.md" ~/.codex/AGENTS.md

# codex config: overwrite from tracked on every run (tracked is source of truth; CLI runtime writes are reset)
rm -f ~/.codex/config.toml
cp "${cdir}/.config/ai-agent/codex-config.toml" ~/.codex/config.toml

# AI agent settings
rm -f ~/.claude/settings.json
# gemini/copilot mcp config: overwrite from tracked on every run
rm -f ~/.gemini/settings.json ~/.copilot/mcp-config.json
cp "${cdir}/.config/ai-agent/mcp-servers.json" ~/.gemini/settings.json
cp "${cdir}/.config/ai-agent/mcp-servers.json" ~/.copilot/mcp-config.json

# claude settings.json = claude-config.json + mcpServers merged
if [ -x "$(command -v jq)" ]; then
	mcp_servers=$(jq '.mcpServers' "${cdir}/.config/ai-agent/mcp-servers.json")
	jq --argjson mcp "$mcp_servers" '. + { mcpServers: $mcp }' \
		"${cdir}/.config/ai-agent/claude-config.json" > ~/.claude/settings.json
else
	echo "Warning: jq not found, copying claude-config.json without mcpServers" >&2
	cp "${cdir}/.config/ai-agent/claude-config.json" ~/.claude/settings.json
fi

# ===============
# other links
# ===============
ln -sf ${cdir}/.zshenv ~/.zshenv
ln -sf ${cdir}/_shell/dircolors ~/.dircolors

ln -sf ${cdir}/others/.textlintrc ~/.textlintrc
if [ ! -d ~/.local/share/deno_ts ]; then
	mkdir -p ~/.local/share/deno_ts
fi
ln -sf ${cdir}/others/textlint.ts ~/.local/share/deno_ts/textlint.ts

ln -sf ${cdir}/.xprofile ~/.xprofile

# ===============
# review-response plugin
# ===============
if command -v codex &>/dev/null; then
	codex plugin marketplace add "${cdir}/.config/ai-agent"
fi

if command -v gemini &>/dev/null; then
	if [ ! -d "${HOME}/.gemini/extensions/review-response" ]; then
		gemini extensions link --consent "${cdir}/.config/ai-agent/plugins/review-response"
	fi
fi

echo "complete!"
