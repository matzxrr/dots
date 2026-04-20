#!/bin/bash
# Bootstrap: install toolchain managers (runs once per machine)
set -euo pipefail

echo "==> Bootstrap: toolchain managers"

# Rustup / cargo
if ! command -v rustup >/dev/null 2>&1; then
    echo "--> installing rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    . "$HOME/.cargo/env"
fi

# NVM
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    echo "--> installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
    export NVM_DIR="$HOME/.nvm"
    . "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm alias default lts/*
fi

# Go
if ! command -v go >/dev/null 2>&1; then
    echo "--> installing go"
    GO_VERSION="1.24.2"
    GO_ARCH="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -o /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
fi

echo "==> Bootstrap complete"
