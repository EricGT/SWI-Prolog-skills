# SWI-Prolog PR Creation Workflow
# Handles complete PR workflow with automatic verification
# Usage: .\pr-workflow.ps1

param(
    [switch]$SkipVerification = $false
)

$ErrorActionPreference = 'Stop'

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

# Validate GitHub user is set
if (-not $env:GITHUB_USER) {
    Write-Host "[ERROR] GITHUB_USER environment variable not set" -ForegroundColor Red
    Write-Host "Set it manually: `$env:GITHUB_USER = 'YourGitHubUsername'" -ForegroundColor Red
    exit 1
}

# Repository mapping
$repo_mapping = @{
    'swipl-devel' = 'SWI-Prolog/swipl-devel'
    'packages/libedit/libedit' = 'SWI-Prolog/winlibedit'
    'packages/bdb' = 'SWI-Prolog/packages-bdb'
    'packages/clib' = 'SWI-Prolog/packages-clib'
    'packages/cpp' = 'SWI-Prolog/packages-cpp'
    'packages/jpl' = 'SWI-Prolog/packages-jpl'
    'packages/libedit' = 'SWI-Prolog/packages-libedit'
    'packages/nlp' = 'SWI-Prolog/packages-nlp'
    'packages/pcre' = 'SWI-Prolog/packages-pcre'
    'packages/semweb' = 'SWI-Prolog/packages-semweb'
    'packages/xpce' = 'SWI-Prolog/packages-xpce'
    'debian' = 'SWI-Prolog/distro-debian'
}

function Detect-Repository {
    $current_path = (Get-Location).Path -replace '\\', '/'

    foreach ($pattern in @('packages/libedit/libedit', 'packages/bdb', 'packages/clib', 'packages/cpp',
                           'packages/jpl', 'packages/libedit', 'packages/nlp', 'packages/pcre',
                           'packages/semweb', 'packages/xpce', 'debian', 'swipl-devel')) {
        if ($current_path -match [regex]::Escape($pattern) + '$') {
            return @{
                pattern = $pattern
                upstream = $repo_mapping[$pattern]
            }
        }
    }

    throw "Not in a recognized SWI-Prolog repository"
}

function Run-VerificationChecks {
    Write-Host ""
    Write-Host "Pre-PR Verification" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    Write-Host ""

    # Check 1: Commits
    Write-Host "Checking commits against upstream/master..."
    $commits = @(git log upstream/master..HEAD --oneline 2>$null)
    $merges = @(git log upstream/master..HEAD --merges --oneline 2>$null)

    if ($merges.Count -gt 0) {
        Write-Host "✗ Commit verification FAILED" -ForegroundColor Red
        Write-Host "  Found $($merges.Count) merge commit(s) - not allowed in PRs" -ForegroundColor Red
        Write-Host ""
        Write-Host "Merge commits found:" -ForegroundColor Red
        $merges | ForEach-Object { Write-Host "  $_" }
        throw "Commit verification failed"
    }

    Write-Host "✓ Commit verification: $($commits.Count) commit(s), no merge commits" -ForegroundColor Green
    if ($commits.Count -gt 0) {
        $commits | ForEach-Object { Write-Host "  $_" }
    }

    # Check 2: Files
    Write-Host ""
    Write-Host "Checking changed files..."
    $files = @(git diff upstream/master..HEAD --name-only 2>$null)
    Write-Host "✓ Files verification: $($files.Count) file(s) changed" -ForegroundColor Green
    if ($files.Count -gt 0) {
        $files | ForEach-Object { Write-Host "  - $_" }
    }

    # Check 3: .gitignore
    Write-Host ""
    Write-Host "Checking .gitignore changes..."
    $gitignore_diff = git diff upstream/master..HEAD -- .gitignore '**/.gitignore' 2>$null

    if ($gitignore_diff) {
        Write-Host "⚠ WARNING: .gitignore changes detected" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Do you want to include .gitignore changes in the PR?"
        Write-Host "(Normally .gitignore changes should not be sent upstream)"
        Write-Host ""
        $response = Read-Host "Include .gitignore? (y/N)"

        if ($response -notmatch '^[Yy]$') {
            throw ".gitignore changes not approved for PR"
        }
    } else {
        Write-Host "✓ No .gitignore changes" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Branch state: CLEAN - Ready for PR ✓" -ForegroundColor Green
}

function Create-PullRequest {
    param(
        [string]$upstream_repo,
        [string]$current_branch
    )

    Write-Host ""
    Write-Host "Creating PR..." -ForegroundColor Cyan
    Write-Host ""

    # Get commit message
    $commit_msg = git log -1 --pretty=%B
    $pr_title = ($commit_msg -split "`n")[0]
    $pr_body = ($commit_msg -split "`n" | Select-Object -Skip 2) -join "`n"

    Write-Host "Title: $pr_title" -ForegroundColor Cyan
    Write-Host "Body:" -ForegroundColor Cyan
    Write-Host "$pr_body"
    Write-Host ""

    Write-Host "Executing: gh pr create --repo $upstream_repo..." -ForegroundColor Yellow

    try {
        $pr_url = gh pr create --repo $upstream_repo --head "$($env:GITHUB_USER):$current_branch" `
            --title "$pr_title" --body "$pr_body" 2>&1

        Write-Host "✓ PR created successfully!" -ForegroundColor Green
        Write-Host "URL: $pr_url" -ForegroundColor Green
        return $pr_url
    }
    catch {
        if ($_ -match 'not found') {
            Write-Host "ERROR: Repository not found - GitHub fork may not exist" -ForegroundColor Red
            Write-Host ""
            Write-Host "To create the fork:" -ForegroundColor Yellow
            Write-Host "1. Go to: https://github.com/SWI-Prolog/$($upstream_repo -split '/')[-1]"
            Write-Host "2. Click 'Fork' button (top right)"
            Write-Host "3. Wait for fork to be created"
            Write-Host "4. Test: git push origin master"
            Write-Host "5. Retry: ./pr-workflow.ps1"
        }
        throw $_
    }
}

# Main workflow
try {
    Write-Host ""
    Write-Host "SWI-Prolog PR Creation Workflow" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan

    # Detect repository
    $repo_info = Detect-Repository
    $current_branch = git branch --show-current

    Write-Host ""
    Write-Host "Repository: $($repo_info.pattern)" -ForegroundColor Cyan
    Write-Host "Upstream: $($repo_info.upstream)" -ForegroundColor Cyan
    Write-Host "Branch: $current_branch" -ForegroundColor Cyan

    # Verify branch is pushed
    Write-Host ""
    Write-Host "Verifying branch is pushed..."
    $branch_exists = git ls-remote --exit-code --heads origin $current_branch 2>$null

    if (-not $branch_exists) {
        throw "Branch not pushed to origin. Run git push -u origin $current_branch"
    }
    Write-Host "✓ Branch is pushed to origin" -ForegroundColor Green

    # Run verification checks
    if (-not $SkipVerification) {
        Run-VerificationChecks
    }

    # Create PR
    $prArgs = @{
        upstream_repo  = $repo_info.upstream
        current_branch = $current_branch
    }
    Create-PullRequest @prArgs

    Write-Host ""
    Write-Host "✓ PR workflow complete!" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
