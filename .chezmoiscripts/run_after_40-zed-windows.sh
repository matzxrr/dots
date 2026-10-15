#!/usr/bin/env bash
# Mirror ~/.config/zed to the Windows-side Zed config (%APPDATA%\Zed) on WSL.
# Runs on every apply; only copies files that differ, backing up the old copy.
set -euo pipefail

grep -qi microsoft /proc/version 2>/dev/null || exit 0
command -v wslpath >/dev/null || exit 0

appdata=$(cd /mnt/c && cmd.exe /c 'echo %APPDATA%' 2>/dev/null | tr -d '\r')
[ -n "$appdata" ] || { echo "zed-windows: could not resolve %APPDATA%, skipping" >&2; exit 0; }

src="$HOME/.config/zed"
dest="$(wslpath "$appdata")/Zed"
backup="$HOME/.cache/zed-windows-backup/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$dest"
for f in settings.json keymap.json; do
    [ -f "$src/$f" ] || continue
    if [ -f "$dest/$f" ] && cmp -s "$src/$f" "$dest/$f"; then
        continue
    fi
    if [ -f "$dest/$f" ]; then
        mkdir -p "$backup"
        cp "$dest/$f" "$backup/$f"
        echo "zed-windows: $f differed on Windows; old copy saved to $backup/$f"
    fi
    cp "$src/$f" "$dest/$f"
    echo "zed-windows: synced $f -> $dest/$f"
done
