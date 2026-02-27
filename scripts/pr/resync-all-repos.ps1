# Resync all SWI-Prolog repositories (main + packages) with upstream
# Fetches latest from upstream, resets local master branches, and pushes to forks.

$ErrorActionPreference = 'Continue'
$WarningPreference = 'Continue'

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

# ============================================================================
# REPOSITORY PATHS (from environment variables)
# ============================================================================
$sourceDir = $env:SWIPL_SOURCE_DIR
$repos = @(
    @{ Name = "swipl-devel"; Path = $sourceDir },
    @{ Name = "packages-bdb"; Path = "$sourceDir\packages\bdb" },
    @{ Name = "packages-clib"; Path = "$sourceDir\packages\clib" },
    @{ Name = "packages-pcre"; Path = "$sourceDir\packages\pcre" },
    @{ Name = "packages-cpp"; Path = "$sourceDir\packages\cpp" },
    @{ Name = "packages-jpl"; Path = "$sourceDir\packages\jpl" },
    @{ Name = "packages-libedit"; Path = "$sourceDir\packages\libedit" },
    @{ Name = "packages-nlp"; Path = "$sourceDir\packages\nlp" },
    @{ Name = "packages-semweb"; Path = "$sourceDir\packages\semweb" },
    @{ Name = "packages-xpce"; Path = "$sourceDir\packages\xpce" },
    @{ Name = "winlibedit"; Path = "$sourceDir\packages\libedit\libedit" },
    @{ Name = "distro-debian"; Path = "$sourceDir\debian" }
)

function Run-Command {
    param(
        [string]$Command,
        [string]$Description,
        [string]$WorkingDirectory = $null
    )

    Write-Host "  ► $Description" -ForegroundColor Cyan
    Write-Host "    $Command" -ForegroundColor Yellow

    if ($WorkingDirectory) {
        Push-Location $WorkingDirectory
        Invoke-Expression $Command 2>&1 | ForEach-Object { Write-Host "      $_" }
        Pop-Location
    } else {
        Invoke-Expression $Command 2>&1 | ForEach-Object { Write-Host "      $_" }
    }
    Write-Host "    [OK]" -ForegroundColor Green
    Write-Host ""
}

Write-Host ""
Write-Host "SWI-Prolog Repository Sync" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

foreach ($repo in $repos) {
    Write-Host "Repository: $($repo.Name)" -ForegroundColor Blue

    if (-not (Test-Path $repo.Path)) {
        Write-Host "  ERROR: Path not found: $($repo.Path)" -ForegroundColor Red
        Write-Host ""
        continue
    }

    Run-Command "git checkout master" "Checkout master" $repo.Path
    Run-Command "git fetch upstream" "Fetch from upstream" $repo.Path
    Run-Command "git reset --hard upstream/master" "Reset to upstream/master" $repo.Path
    Run-Command "git push origin master --force-with-lease" "Push to origin" $repo.Path
}

Write-Host "Cleanup: Submodules" -ForegroundColor Blue
Run-Command "git submodule update --recursive" "Reset submodules" $sourceDir

Write-Host "============================" -ForegroundColor Cyan
Write-Host "Sync Complete!" -ForegroundColor Cyan
Write-Host ""

