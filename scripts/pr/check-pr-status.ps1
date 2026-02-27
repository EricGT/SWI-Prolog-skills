# Check open PRs across all SWI-Prolog repositories
# Uses gh CLI to list pull requests across main repo and all forked packages

param(
    [string]$Author,
    [string]$State = "open"
)

# ============================================================================
# LOAD ENVIRONMENT CONFIGURATION
# ============================================================================
# Source environment configuration (must happen before any path usage)
# Scripts are in: .claude\skills\scripts\pr\
# Config is in:   .claude\skills\config\ (two levels up: ..\..\config\)
# Resolve symlinks so $PSScriptRoot points to the real directory, not a symlink.
$scriptDir = if ($PSCommandPath) {
    Split-Path -Parent (Get-Item $PSCommandPath).Target -ErrorAction SilentlyContinue
} else { $null }
if (-not $scriptDir) { $scriptDir = $PSScriptRoot }
$configScript = Join-Path $scriptDir "..\..\config\setup-environment.ps1"
if (Test-Path $configScript) {
    . $configScript -SkipValidation
} else {
    Write-Host "[ERROR] Configuration script not found at: $configScript" -ForegroundColor Red
    Write-Host "Please run: .\..\config\setup-environment.ps1" -ForegroundColor Red
    exit 1
}

# Use GITHUB_USER if Author not provided
if (-not $Author) {
    $Author = $env:GITHUB_USER
}

if (-not $Author) {
    Write-Host "[ERROR] GitHub username not found. Set GITHUB_USER or provide -Author parameter." -ForegroundColor Red
    exit 1
}

# Repositories to check
$repos = @(
    "SWI-Prolog/swipl-devel",
    "SWI-Prolog/packages-bdb",
    "SWI-Prolog/packages-clib",
    "SWI-Prolog/packages-pcre",
    "SWI-Prolog/packages-cpp",
    "SWI-Prolog/packages-jpl",
    "SWI-Prolog/packages-libedit",
    "SWI-Prolog/packages-nlp",
    "SWI-Prolog/packages-semweb",
    "SWI-Prolog/packages-xpce",
    "SWI-Prolog/winlibedit",
    "SWI-Prolog/distro-debian"
)

Write-Host ""
Write-Host "SWI-Prolog PR Status Check" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host "Author: $Author" -ForegroundColor Yellow
Write-Host "State: $State" -ForegroundColor Yellow
Write-Host ""

$totalPRs = 0

foreach ($repo in $repos) {
    Write-Host "Repository: $repo" -ForegroundColor Blue

    try {
        $output = gh pr list --repo $repo --author $Author --state $State 2>&1

        if ($output -contains "No pull requests found") {
            Write-Host "  No PRs found" -ForegroundColor Gray
        } elseif ($output -and $output.Count -gt 0 -and $output[0] -notmatch "^No") {
            foreach ($line in $output) {
                if ($line -and $line.Trim().Length -gt 0 -and -not ($line -match "^No")) {
                    Write-Host "  $line" -ForegroundColor Green
                    $totalPRs++
                }
            }
        } else {
            Write-Host "  No PRs found" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Error querying PRs: $_" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "============================" -ForegroundColor Cyan
Write-Host "Total PRs Found: $totalPRs" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""
