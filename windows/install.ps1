# Install Windows apps via winget and deploy WSL-side configs to Windows.
# Usage: from PowerShell, run one of:
#   .\install.ps1                    # auto-detect profile from chezmoi
#   .\install.ps1 -Profile personal
#   .\install.ps1 -Profile work

param(
    [ValidateSet("personal", "work")]
    [string]$Profile
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------
# 0. Resolve WSL paths (used for both profile detection and config deploy)
# ---------------------------------------------------------------------
$wslDistro = "Ubuntu"
$wslUser = (wsl -d $wslDistro --exec whoami).Trim()
$wslHome = "\\wsl$\$wslDistro\home\$wslUser"
$wslConfig = "$wslHome\.config"

# ---------------------------------------------------------------------
# 1. Determine profile (personal vs work)
# ---------------------------------------------------------------------
if (-not $Profile) {
    $chezmoiToml = "$wslConfig\chezmoi\chezmoi.toml"
    if (Test-Path $chezmoiToml) {
        $match = Select-String -Path $chezmoiToml -Pattern '^\s*machine\s*=\s*"([^"]+)"'
        if ($match) {
            $machineType = $match.Matches[0].Groups[1].Value
            $Profile = if ($machineType -like "work-*") { "work" } else { "personal" }
            Write-Host "==> Detected profile: $Profile (chezmoi machine = $machineType)" -ForegroundColor Cyan
        }
    }
    if (-not $Profile) {
        Write-Error "Could not detect profile. Run with -Profile personal or -Profile work."
        exit 1
    }
}

# ---------------------------------------------------------------------
# 2. Install apps via winget (base + profile-specific)
# ---------------------------------------------------------------------
function Read-AppList($path) {
    if (-not (Test-Path $path)) { return @() }
    Get-Content $path |
        Where-Object { $_ -and ($_ -notmatch '^\s*#') } |
        ForEach-Object { $_.Trim() }
}

$baseApps = Read-AppList (Join-Path $PSScriptRoot "apps-base.txt")
$extraApps = Read-AppList (Join-Path $PSScriptRoot "apps-$Profile.txt")
$apps = @($baseApps) + @($extraApps)

Write-Host "==> Installing $($apps.Count) apps via winget ($($baseApps.Count) base + $($extraApps.Count) $Profile)" -ForegroundColor Cyan

foreach ($app in $apps) {
    Write-Host ""
    Write-Host "--> $app" -ForegroundColor Yellow
    winget install --id $app --accept-source-agreements --accept-package-agreements -e
}

# ---------------------------------------------------------------------
# 3. Deploy WSL-side configs to Windows %APPDATA%
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "==> Deploying configs from WSL" -ForegroundColor Cyan

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
