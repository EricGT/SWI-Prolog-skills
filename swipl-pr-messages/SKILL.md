---
name: swipl-pr-messages
description: Generate properly formatted SWI-Prolog pull request titles and body messages following project conventions. Use when creating PRs for SWI-Prolog repositories (swipl-devel, packages-clib, packages-pcre, packages-xpce, etc.).
---

# SWI-Prolog Pull Request Messages

## Overview

This skill covers PR titles and bodies. **PRs require a commit message first**—they go hand-in-hand.

**The documentation workflow:**

```
1. Write code (C or Prolog)
   ↓
2. Consult code documentation skill
   - /swipl-c-code-documentation (for C code)
   - /swipl-prolog-code-documentation (for Prolog code)
   ↓
3. Write commit message
   Consult /swipl-git-commit-messages
   ↓
4. Create PR (if needed)
   This skill: /swipl-pr-messages
```

**Key insight:** Commit messages document the *why* in detail. PR messages are brief context for reviewers, referencing the commit message for full details.

## Title Format

PR titles use a category prefix followed by a brief description:

```
PREFIX: Brief description of change
```

**Keep PR titles to 40-50 characters maximum.** They appear in SWI-Prolog release topics on Discourse where users see them—they need to be concise and scannable.

### Title Prefixes

| Prefix | Use For | Example |
|--------|---------|---------|
| `FIXED:` | Bug fixes | `FIXED: crypt/2 memory corruption` |
| `ADDED:` | New features | `ADDED: process_which/2` |
| `ENHANCED:` | Improvements | `ENHANCED: rewrite_host/3 for tcp` |
| `MODIFIED:` | Behavior changes | `MODIFIED: term_hash/2 range` |
| `DOC:` | Documentation only | `DOC: thread_property/2 debug` |
| `PORT:` | Portability fixes | `PORT: 4Mb C-stack default Windows` |
| `BUILD:` | Build system, CMake, CI/CD | `BUILD: MSVC MSB8065 output fix` |
| `TEST:` | Test additions/fixes | `TEST: term_hash/2 indirect types` |
| `CLEANUP:` | Code cleanup, refactoring | `CLEANUP: uninitialized variable` |
| `COMPAT:` | API/version compatibility | `COMPAT: PL_dispatch() API` |
| `WASM:` | WebAssembly specific | `WASM: stack_strings() interface` |

### Title Guidelines

- **40-50 characters maximum** (appears in release notes and Discourse)
- Use past tense: `FIXED:`, `ADDED:` (not `FIX:`, `ADD:`)
- Be specific but brief: `FIXED: socket.c compilation` not just `FIXED: bug`
- Remove redundancy: `ADDED: process_which/2` not `ADDED: New process_which/2 predicate`
- Mention affected component when needed: `ENHANCED: tcp_connect/3`

## Pre-PR Checklist

**⚠️ CRITICAL: Fork Must Exist Before Creating PR**

If you get an error like `fatal: repository 'https://github.com/<YOUR_GITHUB_USER>/<package>.git/' not found`, the GitHub fork doesn't exist yet. See the **Fork Setup** section in the `/swipl-git-workflow` skill for instructions on creating the fork.

**CRITICAL: Always verify branch contents against `upstream/master`, NOT local `master`.**

Before creating a PR, run these verification commands in Git Bash:

### 1. Check All Commits in Branch

```bash
git log upstream/master..HEAD --oneline
```

**What to look for:**
- Only commits related to your PR should be listed
- No merge commits like "Merge remote-tracking branch 'upstream/master'"
- No unrelated commits (e.g., `.gitignore` changes, other fixes)

**If you see extra commits:** The branch is polluted. Create a clean branch (see Recovery section below).

### 2. Check All Changed Files

```bash
git diff upstream/master..HEAD --name-only
```

**What to look for:**
- Only files you intended to change should be listed
- No `.gitignore` files unless explicitly part of your PR
- No unrelated files

**If you see extra files:** The branch contains unintended changes. Create a clean branch.

### 3. Verify No .gitignore Changes (Unless Intended)

```bash
git diff upstream/master..HEAD -- .gitignore **/.gitignore
```

**Expected result:** No output (unless `.gitignore` changes are intentionally part of your PR)

**If output appears:** Ask user if `.gitignore` should be in the PR. If no, create a clean branch.

### Recovery: Creating a Clean Branch

If verification fails (extra commits or files detected):

```bash
# Identify the commit(s) you want to keep
git log upstream/master..HEAD --oneline

# Create clean branch from upstream/master
git checkout upstream/master
git checkout -b <feature-name>-clean

# Cherry-pick only your intended commits
git cherry-pick <commit-hash>  # repeat for each wanted commit

# Verify the clean branch
git diff upstream/master..HEAD --name-only

# Push clean branch
git push origin <feature-name>-clean
```

### Why Compare Against `upstream/master`?

- ✅ **Correct:** `git diff upstream/master..HEAD` - shows what GitHub will show in your PR
- ❌ **Wrong:** `git diff master..HEAD` - local master may be out of sync or contain local changes

Local `master` may have:
- Uncommitted local changes
- Commits from other branches you merged
- Out-of-date state (not synced with upstream)

**Always use `upstream/master` as your comparison base for PRs.**

## Body Format

**IMPORTANT: Keep PR bodies concise - maximum 2 lines, preferably 1 line.**

The PR body is NOT the same as the commit message body. The PR body is brief context for the reviewer. **Full details go in the commit message body** (see `/swipl-git-commit-messages` skill).

### Preferred: One-line Body

For most changes, a single line:

```markdown
Details in commit message.
```

Or a brief statement:

```markdown
Fixed MSVC output file handling in cmake/QLF.cmake.
```

### Maximum: Two-line Body

Only when context is especially helpful:

```markdown
Fixed MSVC MSB8065 warnings for custom build outputs.
Touch OUTPUT files to satisfy MSBuild's requirement.
```

### For Discussion Links

Reference Discourse discussions:

```markdown
See discussion: https://swi-prolog.discourse.group/t/topic-slug/1234
```

## Examples (Brief Format)

### FIXED: Bug Fix

**Title:** `FIXED: crypt/2 on Windows using bsd-crypt.c: possible memory corruption`

**Body:** (empty - self-explanatory from title)

### ADDED: New Feature

**Title:** `ADDED: process_create/3: specify program as prolog(Tool)`

**Body:** `Allows Prolog to run its tools from the same version via prolog:prolog_tool/4 hook.`

### ENHANCED: Improvement

**Title:** `ENHANCED: Make rewrite_host/3 hook work for tcp_connect/3`

**Body:** `Also allows tcp_connect/3 to accept IP numbers, avoiding localhost lookup on Windows.`

### PORT: Portability

**Title:** `PORT: Ensure default 4Mb C-stack on Windows`

**Body:** `Otherwise the default is 2Mb for MinGW and 1Mb for MSVC.`

### BUILD: Build System

**Title:** `BUILD: Fix MSVC MSB8065 warnings for custom build outputs`

**Body:** `Touch OUTPUT files on MSVC to satisfy MSBuild's requirement.`

### DOC: Documentation

**Title:** `DOC: thread_property/2 did not document the debug property`

**Body:** (empty)

## Discourse Integration

Link relevant discussions from [SWI-Prolog Discourse](https://swi-prolog.discourse.group/):

```markdown
As mentioned on the Discourse: https://swi-prolog.discourse.group/t/topic-slug/1234
```

Or reference external build logs:

```markdown
See build log: www.stats.ox.ac.uk/pub/bdr/M1-SAN/rswipl/00check.log
```

## Commit Message Format

Commit messages are documented in detail in the `/swipl-git-commit-messages` skill. When creating a PR, your commit message should already follow that skill's guidelines:

- **Title**: 40-50 characters with PREFIX: description
- **Body**: Detailed explanation of why the change was made
- **Source of truth**: Commit message body contains the full explanation; PR body is just brief context

The relationship:

```
Commit Title:  FIXED: crypt/2 memory corruption on Windows
Commit Body:   [Detailed explanation of the bug and fix]
    ↓
PR Title:      FIXED: crypt/2 memory corruption on Windows (same)
PR Body:       [1-2 lines referencing commit message for details]
```

See `/swipl-git-commit-messages` for full guidance.

## Troubleshooting

### Fork Not Found Error

**Error:**
```
fatal: repository 'https://github.com/<YOUR_GITHUB_USER>/<package>.git/' not found
```

**Cause:** The GitHub fork for this package doesn't exist yet.

**Solution:** Refer to the **Fork Setup** section in `/swipl-git-workflow` skill for detailed instructions on creating the fork before attempting to push or create a PR.
