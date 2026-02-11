# SWI-Prolog Git Workflow - Implementation Examples

Detailed implementation guidance for each workflow operation.

## Status Check Implementation

```bash
# Main repository status
cd /c/dev-MSVC-PR/swipl-devel
echo "=== Main Repository (swipl-devel) ==="
git status --short --branch
echo ""

# Forked packages status (run in parallel for speed)
echo "=== Forked Packages ==="
for pkg in bdb clib cpp jpl libedit nlp pcre semweb xpce; do
    echo "--- packages/$pkg ---"
    (cd packages/$pkg && git status --short --branch)
    echo ""
done

# Nested winlibedit submodule
echo "--- winlibedit (nested in libedit) ---"
(cd packages/libedit/libedit && git status --short --branch)
```

**Enhanced status with ahead/behind info:**

```bash
cd /c/dev-MSVC-PR/swipl-devel
for pkg in . packages/bdb packages/clib packages/cpp packages/jpl \
           packages/libedit packages/nlp packages/pcre packages/semweb \
           packages/xpce packages/libedit/libedit; do
    echo "=== $pkg ==="
    (cd $pkg && git status -sb && echo "")
done
```

## Branch Creation Implementation

### Detect Current Location

```bash
# Get absolute path
current_path=$(pwd)

# Determine which repository/package
if [[ "$current_path" == *"/packages/libedit/libedit"* ]]; then
    repo_name="winlibedit"
    repo_type="nested-submodule"
elif [[ "$current_path" == *"/packages/bdb"* ]]; then
    repo_name="packages-bdb"
    repo_type="submodule"
elif [[ "$current_path" == *"/packages/clib"* ]]; then
    repo_name="packages-clib"
    repo_type="submodule"
# ... (repeat for other packages)
elif [[ "$current_path" == *"/swipl-devel"* ]]; then
    repo_name="swipl-devel"
    repo_type="main"
else
    echo "Error: Not in SWI-Prolog PR directory"
    exit 1
fi

echo "Current location: $repo_name ($repo_type)"
```

### Create Branch

```bash
#!/bin/bash

branch_name="$1"

if [ -z "$branch_name" ]; then
    echo "Error: Branch name required"
    echo "Usage: /swipl-git-workflow branch <name>"
    exit 1
fi

# Check current branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "master" ]; then
    echo "Warning: Not on master branch (currently on: $current_branch)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: Working tree has uncommitted changes"
    git status --short
    exit 1
fi

# Create and checkout branch
git checkout -b "$branch_name"

# Verify
echo ""
echo "Branch created successfully:"
git branch --show-current
git status
```

## Push Implementation

```bash
#!/bin/bash

# Get current branch
current_branch=$(git branch --show-current)

# Verify not on master
if [ "$current_branch" = "master" ]; then
    echo "Error: Cannot push master branch directly"
    echo "Create a feature branch first: /swipl-git-workflow branch <name>"
    exit 1
fi

# Check if branch exists on remote
if git ls-remote --exit-code --heads origin "$current_branch" >/dev/null 2>&1; then
    echo "Branch exists on remote, pushing updates..."
    git push origin "$current_branch"
else
    echo "New branch, pushing with tracking..."
    git push -u origin "$current_branch"
fi

# Show result
echo ""
echo "Pushed to: $(git remote get-url origin)"
echo "Branch: $current_branch"
```

## PR Creation Implementation

### Package Detection and Mapping

```bash
# Detect package and map to upstream repository
detect_upstream_repo() {
    local current_path=$(pwd)

    if [[ "$current_path" == *"/packages/libedit/libedit"* ]]; then
        echo "SWI-Prolog/winlibedit"
    elif [[ "$current_path" == *"/packages/bdb"* ]]; then
        echo "SWI-Prolog/packages-bdb"
    elif [[ "$current_path" == *"/packages/clib"* ]]; then
        echo "SWI-Prolog/packages-clib"
    elif [[ "$current_path" == *"/packages/cpp"* ]]; then
        echo "SWI-Prolog/packages-cpp"
    elif [[ "$current_path" == *"/packages/jpl"* ]]; then
        echo "SWI-Prolog/packages-jpl"
    elif [[ "$current_path" == *"/packages/libedit"* ]]; then
        echo "SWI-Prolog/packages-libedit"
    elif [[ "$current_path" == *"/packages/nlp"* ]]; then
        echo "SWI-Prolog/packages-nlp"
    elif [[ "$current_path" == *"/packages/pcre"* ]]; then
        echo "SWI-Prolog/packages-pcre"
    elif [[ "$current_path" == *"/packages/semweb"* ]]; then
        echo "SWI-Prolog/packages-semweb"
    elif [[ "$current_path" == *"/packages/xpce"* ]]; then
        echo "SWI-Prolog/packages-xpce"
    elif [[ "$current_path" == *"/swipl-devel"* ]]; then
        echo "SWI-Prolog/swipl-devel"
    else
        echo ""
    fi
}
```

### Check for .gitignore Changes

```bash
# Check if .gitignore was modified in this branch
base_branch="master"
current_branch=$(git branch --show-current)

if git diff "$base_branch...$current_branch" -- .gitignore **/.gitignore | grep -q "^diff"; then
    echo "WARNING: .gitignore file(s) modified in this branch:"
    echo ""
    git diff "$base_branch...$current_branch" -- .gitignore **/.gitignore
    echo ""
    echo "Do you want to include these .gitignore changes in the PR?"
    echo "Local .gitignore preferences should usually not be sent upstream."
    read -p "Include .gitignore changes? (y/N) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please remove .gitignore changes before creating PR:"
        echo "  git checkout $base_branch -- .gitignore"
        echo "  git commit --amend --no-edit"
        exit 1
    fi
fi
```

### Create PR with gh CLI

```bash
#!/bin/bash

# Detect upstream repository
upstream_repo=$(detect_upstream_repo)
current_branch=$(git branch --show-current)

if [ -z "$upstream_repo" ]; then
    echo "Error: Could not determine upstream repository"
    exit 1
fi

# Verify branch is pushed
if ! git ls-remote --exit-code --heads origin "$current_branch" >/dev/null 2>&1; then
    echo "Error: Branch not pushed to origin"
    echo "Run: /swipl-git-workflow push"
    exit 1
fi

# Get PR title and body from user or swipl-pr-messages skill
echo "Use /swipl-pr-messages skill to generate PR title and body"
echo "Then create PR with:"
echo ""
echo "gh pr create --repo $upstream_repo --head EricGT:$current_branch"
```

## Sync Implementation (NO MERGE)

**CRITICAL:** Per Jan's request, we use `git reset --hard` instead of `git merge` to avoid merge commits that make PRs confusing.

### Sync Single Package

```bash
#!/bin/bash

# Verify on master branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "master" ]; then
    echo "Error: Must be on master branch to sync"
    echo "Current branch: $current_branch"
    echo "Run: git checkout master"
    exit 1
fi

# Check if working tree is dirty
if ! git diff-index --quiet HEAD --; then
    echo "Error: Working tree has uncommitted changes"
    echo "Please commit or stash changes before syncing master"
    git status --short
    exit 1
fi

# Fetch from upstream
echo "Fetching from upstream..."
git fetch upstream

# Reset to upstream/master (NO MERGE)
echo "Resetting to upstream/master..."
git reset --hard upstream/master

# Push to your fork (may need force-with-lease if diverged)
echo "Pushing to origin..."
git push origin master --force-with-lease

echo ""
echo "Sync complete! Master now matches upstream exactly."
```

### Sync All Repositories

```bash
#!/bin/bash

echo "=== Syncing Main Repository ==="
cd /c/dev-MSVC-PR/swipl-devel
git checkout master
git fetch upstream
git reset --hard upstream/master  # NO MERGE
git push origin master --force-with-lease

echo ""
echo "=== Syncing Forked Packages ==="

for pkg in bdb clib cpp jpl libedit nlp pcre semweb xpce; do
    echo "--- Syncing packages/$pkg ---"
    cd /c/dev-MSVC-PR/swipl-devel/packages/$pkg
    git checkout master
    git fetch upstream
    git reset --hard upstream/master  # NO MERGE
    git push origin master --force-with-lease
    echo ""
done

echo "--- Syncing winlibedit (nested) ---"
cd /c/dev-MSVC-PR/swipl-devel/packages/libedit/libedit
git checkout master
git fetch upstream
git reset --hard upstream/master  # NO MERGE
git push origin master --force-with-lease

echo ""
echo "=== Updating Submodule References ==="
cd /c/dev-MSVC-PR/swipl-devel
git submodule update

echo ""
echo "Sync complete for all repositories!"
```

## Update Feature Branch Implementation (REBASE, NO MERGE)

**Purpose:** Update your feature branch with the latest upstream changes while keeping history clean.

### Update Current Feature Branch

```bash
#!/bin/bash

# Verify on a feature branch (not master)
current_branch=$(git branch --show-current)
if [ "$current_branch" = "master" ]; then
    echo "Error: Cannot update master branch"
    echo "Use: /swipl-git-workflow sync"
    exit 1
fi

# Fetch latest from upstream
echo "Fetching from upstream..."
git fetch upstream

# Rebase onto upstream/master (NO MERGE)
echo "Rebasing $current_branch onto upstream/master..."
if git rebase upstream/master; then
    echo ""
    echo "✓ Rebase successful!"
    echo ""
    echo "Your commits have been replayed on top of the latest upstream changes."
    echo ""
    echo "Next step: Force-push to your fork (since history was rewritten)"
    echo "  git push origin $current_branch --force-with-lease"
else
    echo ""
    echo "✗ Rebase failed - conflicts need resolution"
    echo ""
    echo "Resolve conflicts in the listed files, then:"
    echo "  git add <resolved-files>"
    echo "  git rebase --continue"
    echo ""
    echo "Or abort the rebase:"
    echo "  git rebase --abort"
fi
```

### Handling Rebase Conflicts

```bash
# When rebase stops due to conflicts:

# 1. Check which files have conflicts
git status

# 2. Edit conflicting files to resolve conflicts
#    Look for conflict markers: <<<<<<<, =======, >>>>>>>

# 3. After resolving, add the files
git add <resolved-files>

# 4. Continue the rebase
git rebase --continue

# 5. Repeat steps 2-4 if there are more conflicts

# 6. When rebase completes, force-push
git push origin <branch> --force-with-lease
```

### Why Rebase Instead of Merge?

```bash
# ❌ BAD: Using merge creates merge commit (confusing PRs)
git fetch upstream
git merge upstream/master  # Creates merge commit
git push origin feature-branch

# Result in PR:
# - Commit A (your work)
# - Commit B (your work)
# - Merge commit (confusing!)
# - Commit C (your work)

# ✅ GOOD: Using rebase keeps linear history
git fetch upstream
git rebase upstream/master  # Replays commits on top
git push origin feature-branch --force-with-lease

# Result in PR:
# - Commit A (your work, rebased)
# - Commit B (your work, rebased)
# - Commit C (your work, rebased)
# Clean, linear history!
```

## Which Package Implementation

```bash
#!/bin/bash

current_path=$(pwd)
repo_name=""
repo_type=""
upstream_repo=""

if [[ "$current_path" == *"/packages/libedit/libedit"* ]]; then
    repo_name="winlibedit"
    repo_type="nested-submodule"
    upstream_repo="SWI-Prolog/winlibedit"
    fork_repo="EricGT/winlibedit"
elif [[ "$current_path" == *"/packages/bdb"* ]]; then
    repo_name="packages-bdb"
    repo_type="submodule"
    upstream_repo="SWI-Prolog/packages-bdb"
    fork_repo="EricGT/packages-bdb"
# ... (other packages)
elif [[ "$current_path" == *"/swipl-devel"* ]]; then
    repo_name="swipl-devel"
    repo_type="main-repository"
    upstream_repo="SWI-Prolog/swipl-devel"
    fork_repo="EricGT/swipl-devel"
else
    echo "Not in SWI-Prolog PR directory"
    exit 1
fi

echo "Repository: $repo_name"
echo "Type: $repo_type"
echo "Upstream: https://github.com/$upstream_repo"
echo "Fork: https://github.com/$fork_repo"
echo ""
echo "Current branch: $(git branch --show-current)"
echo "Working directory: $current_path"
```

## Integration Testing Pattern

```bash
#!/bin/bash

# List of feature branches to test together
branches=(
    "fix-msvc-socket-warning"
    "add-ipv6-support"
    "enhance-error-messages"
)

# Create integration branch
cd /c/dev-MSVC-PR/swipl-devel/packages/clib
git checkout master
integration_branch="test-all-$(date +%Y%m%d)"
git checkout -b "$integration_branch"

# Merge all feature branches
for branch in "${branches[@]}"; do
    echo "Merging $branch..."
    git merge "$branch" --no-edit
done

echo ""
echo "Integration branch created: $integration_branch"
echo "You can now build and test with all fixes combined"
echo ""
echo "To create PRs, switch back to individual branches:"
for branch in "${branches[@]}"; do
    echo "  git checkout $branch"
    echo "  /swipl-git-workflow pr"
done
```

## Common Error Scenarios

### Branch Exists Locally

```bash
# Error: branch already exists
git checkout -b fix-bug
# fatal: A branch named 'fix-bug' already exists.

# Solution: checkout existing branch or delete it first
git checkout fix-bug
# or
git branch -d fix-bug  # safe delete (merged only)
git branch -D fix-bug  # force delete
```

### Push Rejected (Non-Fast-Forward)

```bash
# Error: remote has changes you don't have
git push origin feature-branch
# ! [rejected] feature-branch -> feature-branch (non-fast-forward)

# Solution: fetch and rebase
git fetch origin
git rebase origin/feature-branch
git push origin feature-branch
```

### Detached HEAD in Submodule

```bash
# Common when submodules are at specific commits
cd packages/clib
git status
# HEAD detached at 1234abcd

# Solution: checkout master
git checkout master
```

### Rebase Conflict During Update

```bash
# Conflict when rebasing onto upstream/master
git rebase upstream/master
# Auto-merging file.c
# CONFLICT (content): Merge conflict in file.c

# Solution: resolve conflicts manually
git status  # see conflicting files
# edit files to resolve conflicts
git add <resolved-files>
git rebase --continue  # NOT git commit!

# If more conflicts, repeat above steps
# When complete, force-push
git push origin <branch> --force-with-lease
```

### Aborting a Rebase

```bash
# If rebase gets too messy, abort and start over
git rebase --abort

# This returns you to the state before the rebase started
```

### Accidental Merge Instead of Rebase

```bash
# If you accidentally merged instead of rebasing
git log --oneline -5
# Shows: Merge commit 'upstream/master' into feature-branch

# Solution: Reset to before the merge
git reflog  # Find commit before merge
git reset --hard HEAD~1  # Undo last commit (the merge)

# Now do it correctly with rebase
git rebase upstream/master
```
