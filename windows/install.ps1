# Install Windows apps via winget and deploy WSL-side configs to Windows.
# Usage: from PowerShell, run:
#   .\install.ps1

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------
# 1. Install apps via winget
# ---------------------------------------------------------------------
$appsFile = Join-Path $PSScriptRoot "apps.txt"

if (-not (Test-Path $appsFile)) {
    Write-Error "apps.txt not found at $appsFile"
    exit 1
}

$apps = Get-Content $appsFile |
    Where-Object { $_ -and ($_ -notmatch '^\s*#') } |
    ForEach-Object { $_.Trim() }

Write-Host "==> Installing $($apps.Count) apps via winget" -ForegroundColor Cyan

foreach ($app in $apps) {
    Write-Host ""
    Write-Host "--> $app" -ForegroundColor Yellow
    winget install --id $app --accept-source-agreements --accept-package-agreements -e
}

# ---------------------------------------------------------------------
# 2. Deploy WSL-side configs to Windows %APPDATA%
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "==> Deploying configs from WSL" -ForegroundColor Cyan

# Adjust this if your WSL distro or username differs
$wslDistro = "Ubuntu"
$wslUser = "matzxrr"
$wslConfig = "\\wsl$\$wslDistro\home\$wslUser\.config"

if (-not (Test-Path $wslConfig)) {
    Write-Warning "WSL config path not found: $wslConfig"
    Write-Warning "Skipping config deployment. (Make sure WSL is running and chezmoi has been applied.)"
} else {
    # Map: wsl source subdir -> windows destination
    $configs = @{
        "alacritty" = "$env:APPDATA\alacritty"
        "zed"       = "$env:APPDATA\Zed"
    }

    foreach ($src in $configs.Keys) {
        $from = Join-Path $wslConfig $src
        $to = $configs[$src]
        if (Test-Path $from) {
            Write-Host "--> $src -> $to" -ForegroundColor Yellow
            New-Item -ItemType Directory -Force -Path $to | Out-Null
            Copy-Item "$from\*" $to -Recurse -Force
        } else {
            Write-Warning "  (missing: $from)"
        }
    }
}

Write-Host ""
Write-Host "==> Done" -ForegroundColor Green
Write-Host "   Re-run this script any time you update configs in WSL." -ForegroundColor DarkGray
