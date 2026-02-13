# Resync all SWI-Prolog repositories (main + packages) with upstream
# Fetches latest from upstream, resets local master branches, and pushes to forks.

param(
    [bool]$DryRun = $true
)

$ErrorActionPreference = 'Continue'
$WarningPreference = 'Continue'

# Repository paths
$repos = @(
    @{ Name = "swipl-devel"; Path = "C:\dev-MSVC-PR\swipl-devel" },
    @{ Name = "packages-bdb"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\bdb" },
    @{ Name = "packages-clib"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\clib" },
    @{ Name = "packages-pcre"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\pcre" },
    @{ Name = "packages-cpp"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\cpp" },
    @{ Name = "packages-jpl"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\jpl" },
    @{ Name = "packages-libedit"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\libedit" },
    @{ Name = "packages-nlp"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\nlp" },
    @{ Name = "packages-semweb"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\semweb" },
    @{ Name = "packages-xpce"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\xpce" },
    @{ Name = "winlibedit"; Path = "C:\dev-MSVC-PR\swipl-devel\packages\libedit\libedit" }
)

function Run-Command {
    param(
        [string]$Command,
        [string]$Description,
        [string]$WorkingDirectory = $null
    )

    Write-Host "  ► $Description" -ForegroundColor Cyan
    Write-Host "    $Command" -ForegroundColor Yellow

    if (-not $DryRun) {
        if ($WorkingDirectory) {
            Push-Location $WorkingDirectory
            Invoke-Expression $Command 2>&1 | ForEach-Object { Write-Host "      $_" }
            Pop-Location
        } else {
            Invoke-Expression $Command 2>&1 | ForEach-Object { Write-Host "      $_" }
        }
        Write-Host "    [OK]" -ForegroundColor Green
    } else {
        Write-Host "    [DRY RUN]" -ForegroundColor Magenta
    }
    Write-Host ""
}

Write-Host ""
Write-Host "SWI-Prolog Repository Sync" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "MODE: DRY RUN (preview only)" -ForegroundColor Yellow
} else {
    Write-Host "MODE: EXECUTING" -ForegroundColor Red
}
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
Run-Command "git submodule update --recursive" "Reset submodules" "C:\dev-MSVC-PR\swipl-devel"

Write-Host "============================" -ForegroundColor Cyan
Write-Host "Sync Complete!" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "To execute, run:" -ForegroundColor Yellow
    Write-Host "  .\resync-all-repos.ps1 -DryRun " + '$' + "false" -ForegroundColor Yellow
}
