#!/usr/bin/env bash
set -e

# txt, md
# packages=("npm:textlint@latest" "npm:textlint-rule-preset-jtf-style@latest" "npm:textlint-rule-preset-ja-technical-writing@latest")

# tex
packages=("npm:textlint@latest" "npm:textlint-rule-preset-jtf-style@latest" "npm:textlint-rule-preset-ja-technical-writing@latest" "npm:textlint-rule-preset-ja-engineering-paper@latest" "npm:textlint-plugin-latex2e")

deno cache --node-modules-dir ${packages[@]}
