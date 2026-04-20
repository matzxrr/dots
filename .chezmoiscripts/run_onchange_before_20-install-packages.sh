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
    (type -p wget >/dev/null || sudo apt-get install -y wget) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt-get update -qq \
    && sudo apt-get install -y gh
fi

# ---- CARGO ----------------------------------------------------------
. "$HOME/.cargo/env"

CARGO_PACKAGES=(
    bacon          # background rust linter
    helix-term     # the helix editor (hx)
    just           # command runner
    starship       # prompt
    taplo-cli      # TOML LSP
)

for pkg in "${CARGO_PACKAGES[@]}"; do
    # extract binary name from package (helix-term → hx, taplo-cli → taplo)
    case "$pkg" in
        helix-term) bin="hx" ;;
        taplo-cli)  bin="taplo" ;;
        *)          bin="$pkg" ;;
    esac
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "--> cargo install $pkg"
        cargo install --locked "$pkg"
    fi
done

# Rust components
rustup component add rust-analyzer clippy rustfmt 2>/dev/null || true

# ---- GO -------------------------------------------------------------
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

GO_PACKAGES=(
    golang.org/x/tools/gopls@latest
    golang.org/x/tools/cmd/goimports@latest
    github.com/go-delve/delve/cmd/dlv@latest
    honnef.co/go/tools/cmd/staticcheck@latest
    github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
    github.com/nametake/golangci-lint-langserver@latest
    github.com/bufbuild/buf/cmd/buf@latest
    github.com/bazelbuild/buildtools/buildifier@latest
    github.com/bazelbuild/bazelisk@latest
    github.com/jesseduffield/lazygit@latest
    github.com/air-verse/air@latest
    github.com/cosmtrek/air@latest
)

for pkg in "${GO_PACKAGES[@]}"; do
    echo "--> go install $pkg"
    go install "$pkg" || echo "    (skipped: $pkg)"
done

# ---- NPM (global, via NVM's current node) ---------------------------
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

NPM_PACKAGES=(
    @biomejs/biome
    typescript
    typescript-language-server
    vscode-langservers-extracted    # css, html, json, eslint
    yaml-language-server
    tailwindcss-language-server
    bash-language-server
    emmet-language-server
    prettier
    pyright
    diff-so-fancy
)

echo "--> npm install -g"
npm install -g "${NPM_PACKAGES[@]}"

echo "==> Packages installed"
