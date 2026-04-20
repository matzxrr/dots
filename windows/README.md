# Windows setup

Bootstraps a fresh Windows machine using [winget](https://learn.microsoft.com/en-us/windows/package-manager/).

## Prerequisites

- Windows 10 (1809+) or Windows 11 — winget is pre-installed.
- If winget is missing, grab it from the Microsoft Store: "App Installer".

## One-time setup

From PowerShell, allow local scripts to run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Running the installer

### Option 1 — clone the repo on Windows

```powershell
git clone git@github.com:matzxrr/dots.git $env:USERPROFILE\dots
cd $env:USERPROFILE\dots\windows
.\install.ps1
```

### Option 2 — run from WSL via the `\\wsl$` share

(When WSL is set up first and you want to avoid a second clone.)

```powershell
cd \\wsl$\Ubuntu\home\matzxrr\.local\share\chezmoi\windows
.\install.ps1
```

## Editing the app list

Apps live in `apps.txt` — one winget package ID per line. Lines starting
with `#` are comments. To find a package ID:

```powershell
winget search <app-name>
```

## Useful winget commands

| Command | What it does |
|---|---|
| `winget list` | Show installed apps |
| `winget upgrade` | List available updates |
| `winget upgrade --all` | Update everything |
| `winget uninstall <id>` | Remove an app |
| `winget search <term>` | Find a package |

## What the installer does

`install.ps1` does two things:

1. Installs every app listed in `apps.txt` via `winget install`
2. Copies configs from WSL to Windows `%APPDATA%`:
   - `~/.config/alacritty/` → `%APPDATA%\alacritty\`
   - `~/.config/zed/`       → `%APPDATA%\Zed\`

Re-run `install.ps1` whenever you update configs on the WSL side and
want the same changes reflected in Windows.

> **Why not a symlink?** `\\wsl$\...` paths require WSL to be running.
> A static copy in `%APPDATA%` means Alacritty and Zed work even before
> WSL starts.
