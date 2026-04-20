# dots

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Targets Ubuntu / WSL2 on the Linux side, Windows 10/11 on the desktop side.

## What's inside

- **Shell** — bash with starship prompt
- **Editor** — Zed (Windows) + vim (terminal fallback)
- **Terminal** — Alacritty on Windows, tmux in WSL
- **Git** — templated config with folder-based identity overrides (work vs personal)
- **Tools** — go, rust, node via rustup / nvm / manual install
- **Windows apps** — winget-driven app list in `windows/`

## Bootstrap a new Linux / WSL machine

```bash
sudo apt update && sudo apt install -y git curl
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply matzxrr
```

Chezmoi will:
1. Clone this repo to `~/.local/share/chezmoi`
2. Prompt for machine type (`personal`, `work-blade`, `work-laptop`) and GPG keys
3. Run the bootstrap script (rustup, nvm, go)
4. Run the install-packages script (apt / cargo / go / claude)
5. Apply config files

Total time ~15 min on a fresh machine.

## Bootstrap a new Windows machine

From Windows PowerShell:

```powershell
git clone git@github.com:matzxrr/dots.git $env:USERPROFILE\dots
cd $env:USERPROFILE\dots\windows
.\install.ps1
```

If PowerShell blocks the script, run once:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Daily workflow

| Command | What it does |
|---|---|
| `chezmoi edit <file>` | Edit a managed file (opens in source dir) |
| `chezmoi diff` | Preview what would change on apply |
| `chezmoi apply` | Apply changes from source to home |
| `chezmoi add <file>` | Start managing a new file |
| `chezmoi update` | Pull latest + apply |
| `chezmoi cd` | Open a shell in the source dir |
| `chezmoi git -- <args>` | Run git commands in the source dir |

## Machine data

Each machine stores its per-machine data at `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
  machine = "personal"             # or work-blade / work-laptop
  gpg_key = "AA1C7ADD08D44AE0"    # personal signing key (same everywhere)
  is_work = false
  work_gpg_key = ""                # set on work machines
```

## Structure

```
.
├── dot_bashrc                      → ~/.bashrc
├── dot_bash_profile                → ~/.bash_profile
├── dot_tmux.conf                   → ~/.tmux.conf (compat stub)
├── dot_gitconfig.tmpl              → ~/.gitconfig (templated)
├── dot_config/
│   ├── alacritty/                  → ~/.config/alacritty/
│   ├── gitconfig/work.tmpl         → ~/.config/gitconfig/work (work identity)
│   ├── lazygit/
│   ├── starship.toml
│   ├── tmux/
│   └── zed/settings.json
├── .chezmoiscripts/
│   ├── run_once_before_10-bootstrap.sh           # rustup, nvm, go
│   └── run_onchange_before_20-install-packages.sh # apt, cargo, go, claude
├── windows/
│   ├── apps.txt                    # winget package IDs
│   ├── install.ps1                 # winget bulk installer
│   └── README.md
├── .chezmoi.toml.tmpl              # init prompts (machine type, GPG keys)
└── .chezmoiignore                  # patterns to skip
```

## Git identity

The base `.gitconfig` uses personal identity (matzxrr) as default. Work
identity is overridden automatically for repos cloned under `~/work/` via
`includeIf "gitdir:~/work/"`. No manual switching needed — just put work
repos in `~/work/` and personal/side-project repos anywhere else.

## Philosophy

Minimal tinkering. Tools should get out of the way and work. LSPs and
language-specific configuration are handled by Zed's extension system
rather than installed globally.
