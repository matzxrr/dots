#!/bin/bash
# Install packages (re-runs when this file changes)
set -euo pipefail

echo "==> Installing packages"

# ---- APT ------------------------------------------------------------
APT_PACKAGES=(
    build-essential
    curl
    wget
    git
    gnupg
    tmux
    vim
    bat
    ripgrep
    fd-find
    jq
    unzip
    python3
    python3-pip
    pipx
)

echo "--> apt update"
sudo apt-get update -qq

echo "--> apt install"
sudo apt-get install -y "${APT_PACKAGES[@]}"

# gh (GitHub CLI) via their official repo
if ! command -v gh >/dev/null 2>&1; then
    echo "--> installing gh"
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y gh
fi

# ---- CARGO ----------------------------------------------------------
. "$HOME/.cargo/env"

CARGO_PACKAGES=(
    git-delta      # better git diff pager
    just           # command runner
    starship       # prompt
)

for pkg in "${CARGO_PACKAGES[@]}"; do
    case "$pkg" in
        git-delta) bin="delta" ;;
        *)         bin="$pkg" ;;
    esac
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "--> cargo install $pkg"
        cargo install --locked "$pkg"
    fi
done

# ---- GO -------------------------------------------------------------
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

GO_PACKAGES=(
    github.com/bazelbuild/bazelisk@latest
    github.com/jesseduffield/lazygit@latest
)

for pkg in "${GO_PACKAGES[@]}"; do
    echo "--> go install $pkg"
    go install "$pkg" || echo "    (skipped: $pkg)"
done

# ---- NODE -----------------------------------------------------------
# NVM + LTS node are installed by bootstrap.
# No global npm packages — Zed manages its own language tooling.

# ---- AI TOOLS -------------------------------------------------------

# Claude Code (Anthropic's official installer → ~/.local/bin/claude)
if ! command -v claude >/dev/null 2>&1; then
    echo "--> installing claude code"
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo "==> Packages installed"
