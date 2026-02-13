<#
.SYNOPSIS
    Create a new feature branch with suggested naming
.DESCRIPTION
    Creates a new feature branch from master with naming suggestions based on the fix type.
    Follows SWI-Prolog PR conventions for branch naming.
.PARAMETER BranchName
    The name of the branch to create (if not provided, will prompt)
.PARAMETER BranchType
    Type of branch: fix, feature, refactor, test, docs
.PARAMETER Repository
    Path to the repository (default: C:\dev-MSVC-PR\swipl-devel)
.PARAMETER DryRun
    If $true (default), shows commands without executing them.
.EXAMPLE
    # Interactive mode - will suggest naming
    .\setup-new-branch.ps1

    # Create specific branch
    .\setup-new-branch.ps1 -BranchName "fix-boot-debug-autoload"

    # Create in different repo
    .\setup-new-branch.ps1 -BranchName "fix-pcre-unicode" -Repository "C:\dev-MSVC-PR\swipl-devel\packages\pcre"
#>

param(
    [string]$BranchName = "",
    [ValidateSet("fix", "feature", "refactor", "test", "docs")]
    [string]$BranchType = "fix",
    [string]$Repository = "C:\dev-MSVC-PR\swipl-devel",
    [bool]$DryRun = $true
)

$ErrorActionPreference = 'Continue'

function Show-BranchNameSuggestions {
    Write-Host ""
    Write-Host "Branch Naming Suggestions:" -ForegroundColor Cyan
    Write-Host "────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fix (bug fix):" -ForegroundColor Yellow
    Write-Host "  fix-<component>-<issue>"
    Write-Host "  Examples:"
    Write-Host "    fix-boot-debug-autoload" -ForegroundColor Gray
    Write-Host "    fix-msvc-compile-warning" -ForegroundColor Gray
    Write-Host "    fix-pthread-exit-crash" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Feature (new functionality):" -ForegroundColor Yellow
    Write-Host "  add-<component>-<feature>"
    Write-Host "  Examples:"
    Write-Host "    add-pcre-unicode-support" -ForegroundColor Gray
    Write-Host "    add-clib-new-predicate" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Refactor:" -ForegroundColor Yellow
    Write-Host "  refactor-<component>-<what>"
    Write-Host "  Examples:"
    Write-Host "    refactor-clib-error-handling" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Test:" -ForegroundColor Yellow
    Write-Host "  test-<component>-<what>"
    Write-Host "  Examples:"
    Write-Host "    test-tabling-regression" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Documentation:" -ForegroundColor Yellow
    Write-Host "  docs-<what>"
    Write-Host "  Examples:"
    Write-Host "    docs-build-instructions" -ForegroundColor Gray
    Write-Host ""
}

function Run-Command {
    param(
        [string]$Command,
        [string]$Description
    )

    Write-Host "► $Description" -ForegroundColor Cyan
    Write-Host "  $Command" -ForegroundColor Yellow

    if (-not $DryRun) {
        Write-Host "  Executing..." -ForegroundColor Gray
        Invoke-Expression $Command
        Write-Host "  ✓ Done" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN - not executed]" -ForegroundColor Magenta
    }
    Write-Host ""
}

# Verify repository exists
if (-not (Test-Path $Repository)) {
    Write-Host "✗ Repository not found: $Repository" -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Create New Feature Branch" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check current git status
Push-Location $Repository
$currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
$repoName = Split-Path -Leaf $Repository
Pop-Location

Write-Host "Repository: $repoName" -ForegroundColor Yellow
Write-Host "Current branch: $currentBranch" -ForegroundColor Yellow
Write-Host ""

# Get branch name if not provided
if ([string]::IsNullOrWhiteSpace($BranchName)) {
    Show-BranchNameSuggestions
    Write-Host ""
    $BranchName = Read-Host "Enter branch name"

    if ([string]::IsNullOrWhiteSpace($BranchName)) {
        Write-Host "✗ Branch name cannot be empty" -ForegroundColor Red
        exit 1
    }
}

# Validate branch name
if ($BranchName -notmatch '^[a-z0-9\-]+$') {
    Write-Host "✗ Invalid branch name. Use lowercase letters, numbers, and hyphens only." -ForegroundColor Red
    exit 1
}

Write-Host "Branch name: $BranchName" -ForegroundColor Green
Write-Host ""

if ($DryRun) {
    Write-Host "MODE: DRY RUN (preview only)" -ForegroundColor Yellow
} else {
    Write-Host "MODE: EXECUTING COMMANDS" -ForegroundColor Red
}
Write-Host ""

Write-Host "Operations to perform:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Commands to run
Run-Command `
    -Command "git checkout master" `
    -Description "Switch to master branch"

Run-Command `
    -Command "git pull upstream master" `
    -Description "Pull latest from upstream"

Run-Command `
    -Command "git checkout -b $BranchName" `
    -Description "Create and checkout new branch"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "Branch ready to be created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run with -DryRun `$false to create the branch" -ForegroundColor Yellow
    Write-Host "   .\setup-new-branch.ps1 -BranchName '$BranchName' -DryRun `$false" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Make your code changes" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3. Commit and push:" -ForegroundColor Yellow
    Write-Host "   git add <files>" -ForegroundColor Gray
    Write-Host "   git commit -m 'Fix: description'" -ForegroundColor Gray
    Write-Host "   git push origin $BranchName" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Create PR:" -ForegroundColor Yellow
    Write-Host "   gh pr create --repo SWI-Prolog/<package> --head EricGT:$BranchName" -ForegroundColor Gray
} else {
    Write-Host "Branch '$BranchName' created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Make your code changes" -ForegroundColor Yellow
    Write-Host "2. Commit and push:" -ForegroundColor Yellow
    Write-Host "   git add <files>" -ForegroundColor Gray
    Write-Host "   git commit -m 'Fix: description'" -ForegroundColor Gray
    Write-Host "   git push origin $BranchName" -ForegroundColor Gray
    Write-Host "3. Create PR" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
