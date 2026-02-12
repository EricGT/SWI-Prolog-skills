---
name: swipl-git-workflow
description: Git workflow commands for SWI-Prolog PR development. Handles branch creation, status checks, pushing to forks, creating PRs, and syncing with upstream across main repo and forked submodules (bdb, clib, cpp, jpl, libedit, nlp, pcre, semweb, xpce, winlibedit).
---

# SWI-Prolog Git Workflow

Git operations for the SWI-Prolog PR development environment with forked repositories and submodules.

## Available Operations

Use `/swipl-git-workflow <operation>` where operation is one of:

- `status` - Show status of main repo and all forked submodules
- `branch <name>` - Create feature branch in current submodule/repo
- `push` - Push current branch to fork (origin)
- `pr` - Create pull request to upstream
- `sync` - Sync master with upstream (fetch and reset, NO merge)
- `update` - Update feature branch with latest upstream (rebase, NO merge)
- `which-package` - Identify which package directory you're in

## Forked Packages

The following packages are forked and accept PRs:
- `packages/bdb` → packages-bdb
- `packages/clib` → packages-clib
- `packages/cpp` → packages-cpp
- `packages/jpl` → packages-jpl
- `packages/libedit` → packages-libedit
- `packages/nlp` → packages-nlp
- `packages/pcre` → packages-pcre
- `packages/semweb` → packages-semweb
- `packages/xpce` → packages-xpce
- `packages/libedit/libedit` → winlibedit (nested submodule)

All other packages use upstream URLs only (no fork).

## Operation Details

### Status Check (`status`)

Shows git status for main repo and all forked submodules in parallel.

**Example:**
```bash
/swipl-git-workflow status
```

**Actions:**
1. Check main repo: `/c/dev-MSVC-PR/swipl-devel`
2. Check each forked package in parallel
3. Report current branch, dirty files, ahead/behind status

### Create Branch (`branch <name>`)

Creates a feature branch following the branch-first rule.

**Example:**
```bash
/swipl-git-workflow branch fix-msvc-socket-warning
```

**Actions:**
1. Detect current location (main repo or which package)
2. Verify on master branch
3. Ensure working tree is clean
4. Create and checkout new branch
5. Verify branch creation

**Branch-First Rule:** Always create a feature branch before making code changes. NEVER work directly on master.

### Push to Fork (`push`)

Pushes current branch to your fork (origin remote).

**Example:**
```bash
/swipl-git-workflow push
```

**Actions:**
1. Detect current location
2. Verify on a feature branch (not master)
3. Push to origin with tracking: `git push -u origin HEAD`
4. Display push result and remote URL

### Create Pull Request (`pr`)

Creates a PR from your fork to upstream SWI-Prolog repository.

**Example:**
```bash
/swipl-git-workflow pr
```

**Actions:**
1. Detect current location and package
2. Verify branch is pushed to origin
3. **Run pre-PR verification** (see Verification section below)
4. Use `/swipl-pr-messages` skill to generate PR title and body
5. Create PR using `gh pr create --repo SWI-Prolog/<package> --head EricGT:<branch>`

**Pre-PR Verification (MANDATORY):**

Before creating PR, **ALWAYS** run these checks against `upstream/master`:

```bash
# 1. Check all commits in branch
git log upstream/master..HEAD --oneline

# 2. Check all changed files
git diff upstream/master..HEAD --name-only

# 3. Verify no .gitignore changes (unless intended)
git diff upstream/master..HEAD -- .gitignore **/.gitignore
```

**Expected results:**
- Only commits related to your PR
- No merge commits
- Only files you intended to change
- No `.gitignore` unless intentional

**If verification fails:** Create a clean branch using cherry-pick (see Recovery section).

**Repository Mapping:**
- Main: `SWI-Prolog/swipl-devel` ← `EricGT/swipl-devel`
- BDB: `SWI-Prolog/packages-bdb` ← `EricGT/packages-bdb`
- Clib: `SWI-Prolog/packages-clib` ← `EricGT/packages-clib`
- Cpp: `SWI-Prolog/packages-cpp` ← `EricGT/packages-cpp`
- JPL: `SWI-Prolog/packages-jpl` ← `EricGT/packages-jpl`
- Libedit: `SWI-Prolog/packages-libedit` ← `EricGT/packages-libedit`
- NLP: `SWI-Prolog/packages-nlp` ← `EricGT/packages-nlp`
- Pcre: `SWI-Prolog/packages-pcre` ← `EricGT/packages-pcre`
- Semweb: `SWI-Prolog/packages-semweb` ← `EricGT/packages-semweb`
- XPCE: `SWI-Prolog/packages-xpce` ← `EricGT/packages-xpce`
- Winlibedit: `SWI-Prolog/winlibedit` ← `EricGT/winlibedit`

### Sync with Upstream (`sync`)

Syncs master branch with upstream using **fetch + reset** (NO merge commits).

**IMPORTANT:** Per Jan's request, we use `git reset --hard` instead of `git merge` to keep PRs clean. This avoids merge commits that make PR history confusing.

**Example:**
```bash
/swipl-git-workflow sync
/swipl-git-workflow sync clib
/swipl-git-workflow sync all
```

**Actions for single package:**
1. Detect current location (or use specified package)
2. Verify on master branch (error if on feature branch)
3. Ensure working tree is clean (warn if dirty)
4. Fetch from upstream: `git fetch upstream`
5. Reset to upstream: `git reset --hard upstream/master`
6. Push to origin (your fork): `git push origin master --force-with-lease`

**Actions for `sync all`:**
1. Sync main repository
2. Sync all forked packages in sequence
3. Update submodule references: `git submodule update`

**Why no merge?** Merge commits in master create confusing PR history. Using `reset --hard` keeps master identical to upstream without merge commits.

### Update Feature Branch (`update`)

Updates your feature branch with latest upstream changes using **rebase** (NO merge commits).

**Example:**
```bash
# While on your feature branch
/swipl-git-workflow update
```

**Actions:**
1. Verify on a feature branch (not master)
2. Fetch from upstream: `git fetch upstream`
3. Rebase onto upstream/master: `git rebase upstream/master`
4. If conflicts occur, pause and guide user through resolution
5. After successful rebase, suggest force-push: `git push origin <branch> --force-with-lease`

**Why rebase instead of merge?** Rebasing replays your commits on top of the latest upstream changes, keeping PR history linear and clean. Merge commits make PRs confusing to review.

### Which Package (`which-package`)

Identifies which repository/package you're currently in.

**Example:**
```bash
/swipl-git-workflow which-package
```

**Output:**
- Main repository: `swipl-devel`
- Package: `packages-clib`
- Nested submodule: `winlibedit`

## Remote Configuration

All forked repositories use this remote structure:
- `origin` → Your fork (EricGT/*)
- `upstream` → Official SWI-Prolog repository

Push to `origin`, create PRs to `upstream`.

## Clean PR Philosophy

**IMPORTANT:** SWI-Prolog maintainers require clean PR history without merge commits.

**Rules:**
1. ✅ **DO** use `git reset --hard` to sync master with upstream
2. ✅ **DO** use `git rebase` to update feature branches
3. ✅ **DO** use `git merge` for local integration testing (never pushed to PRs)
4. ❌ **DON'T** use `git merge upstream/master` - it creates confusing PRs
5. ❌ **DON'T** create merge commits in branches that will become PRs

**Why?** Merge commits in PR branches make the history confusing to review. Using reset and rebase keeps history linear and clear.

## Integration Testing Pattern

To test multiple independent fixes together without affecting PR history:

1. Keep each fix on its own feature branch
2. Create a **local-only** integration branch:
   ```bash
   git checkout master
   git checkout -b test-all-fixes-20260211
   git merge fix-issue-1    # OK - this branch never becomes a PR
   git merge fix-issue-2    # OK - local testing only
   git merge fix-issue-3    # OK - local testing only
   ```
3. Build and test on the integration branch
4. Create separate PRs from **original feature branches** (not the integration branch)
5. Delete integration branch after testing: `git branch -D test-all-fixes-20260211`

**Note:** Using `merge` here is OK because this integration branch is never pushed or used for PRs. It's purely for local testing.

## Recovery: Creating Clean Branches

If pre-PR verification reveals unwanted commits or files (e.g., `.gitignore` changes, merge commits):

### Problem: Branch Contains Unwanted Commits

**Symptoms:**
- `git log upstream/master..HEAD` shows extra commits (merge commits, unrelated changes)
- `git diff upstream/master..HEAD --name-only` shows unwanted files

**Solution: Cherry-pick to Clean Branch**

```bash
# 1. Identify commits you WANT to keep
git log upstream/master..HEAD --oneline
# Example output:
#   abc1234 BUILD: Fix MSVC warnings  ← KEEP THIS
#   def5678 Ignore Claude Code files  ← UNWANTED

# 2. Create clean branch from upstream/master
git checkout upstream/master
git checkout -b <feature-name>-clean

# 3. Cherry-pick only wanted commits
git cherry-pick abc1234

# 4. Verify clean branch
git log upstream/master..HEAD --oneline  # Should show only wanted commits
git diff upstream/master..HEAD --name-only  # Should show only intended files

# 5. Push clean branch
git push origin <feature-name>-clean

# 6. Create PR with clean branch
gh pr create --repo SWI-Prolog/<package> --head EricGT:<feature-name>-clean ...
```

### Problem: Local `master` Out of Sync

**Symptom:** Comparing against local `master` shows different results than `upstream/master`

**Why it happens:**
- Local `master` may have uncommitted changes
- Local `master` may have commits from other branches
- Local `master` may be behind or ahead of `upstream/master`

**Solution:** Always compare against `upstream/master`:

```bash
# ❌ WRONG - compares against local master
git diff master..HEAD --name-only

# ✅ CORRECT - compares against upstream
git diff upstream/master..HEAD --name-only
```

**Update local master if needed:**
```bash
git checkout master
git fetch upstream
git reset --hard upstream/master
git push origin master --force-with-lease
```

## Common Workflows

### Starting a New Fix

```bash
cd /c/dev-MSVC-PR/swipl-devel/packages/clib
/swipl-git-workflow branch fix-socket-error
# Make changes...
git add <files>
git commit -m "FIXED: Socket error handling on Windows"
/swipl-git-workflow push
/swipl-git-workflow pr
```

### Updating Feature Branch with Latest Upstream

```bash
# While on your feature branch that's behind upstream
/swipl-git-workflow update

# After successful rebase, force-push to your fork
git push origin <branch> --force-with-lease
```

### Checking Everything

```bash
/swipl-git-workflow status
```

### Keeping Master Up to Date

```bash
# Sync master in current package
git checkout master
/swipl-git-workflow sync

# Or sync all packages
/swipl-git-workflow sync all
```

## Notes

- Always use Git Bash for path consistency: `/c/dev-MSVC-PR/swipl-devel`
- Windows CMD uses: `C:\dev-MSVC-PR\swipl-devel`
- **MANDATORY:** The branch-first rule - no code changes on master
- **MANDATORY:** No merge commits in PRs - use reset/rebase only
- PR body formatting uses `/swipl-pr-messages` skill
- `.gitignore` changes trigger a warning before PR creation
- Use `--force-with-lease` (not `--force`) when force-pushing after rebase
