---
name: swipl-pr-messages
description: Generate properly formatted SWI-Prolog pull request titles and body messages following project conventions. Use when creating PRs for SWI-Prolog repositories (swipl-devel, packages-clib, packages-pcre, packages-xpce, etc.).
---

# SWI-Prolog Pull Request Messages

## Title Format

PR titles use a category prefix followed by a brief description:

```
PREFIX: Brief description of change
```

### Title Prefixes

| Prefix | Use For | Example |
|--------|---------|---------|
| `FIXED:` | Bug fixes | `FIXED: Memory leak in re_compile` |
| `ADDED:` | New features or functionality | `ADDED: process_which/2 to find executable` |
| `ENHANCED:` | Improvements to existing features | `ENHANCED: uri_file_name/2 mode (+,-): Allow for file://host/...` |
| `MODIFIED:` | Behavior changes (not bugs) | `MODIFIED: term_hash/2: extended range` |
| `DOC:` | Documentation changes only | `DOC: gcd/2 and lcm/2 are not operators` |
| `PORT:` | Portability fixes (platform, compiler) | `PORT: Ensure default 4Mb C-stack on Windows` |
| `BUILD:` | Build system, CMake, CI/CD | `BUILD: Install pldoc/hooks.pl instead of the .qlf file` |
| `TEST:` | Test additions, fixes, improvements | `TEST: term_hash/2 for indirect data types` |
| `CLEANUP:` | Code cleanup, refactoring | `CLEANUP: Avoid reading uninitialized local variable` |
| `COMPAT:` | API/version compatibility | `COMPAT: Use new PL_dispatch() API` |
| `WASM:` | WebAssembly specific changes | `WASM: Added Prolog.__with_stack_strings()` |

### Title Guidelines

- Keep under 70 characters when possible
- Use `FIXED:` (past tense) not `FIX:` - this is the project convention
- Be specific: `FIXED: MSVC compilation error in socket.c` not `FIXED: bug`
- Mention affected predicate/component: `ADDED: ensure_directory/1`

## Pre-PR Checklist

**⚠️ CRITICAL: Fork Must Exist Before Creating PR**

If you get an error like `fatal: repository 'https://github.com/EricGT/<package>.git/' not found`, the GitHub fork doesn't exist yet. See the **Fork Setup** section in the `/swipl-git-workflow` skill for instructions on creating the fork.

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

## Body Formats

**IMPORTANT: Keep PR bodies concise - maximum 2 lines, preferably 1 line.**

### Preferred: One-line Body

For most changes, a single line explaining what was changed:

```markdown
Modified add_swipl_target() in cmake/QLF.cmake to touch OUTPUT files on MSVC.
```

### Maximum: Two-line Body

Only when absolutely necessary:

```markdown
Modified add_swipl_target() in cmake/QLF.cmake to touch OUTPUT files on MSVC.
This satisfies MSBuild's requirement that custom command outputs must exist.
```

### Exception: External Reference

Or just link to discussion:

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

**CRITICAL: Commit messages must be maximum 2 lines total (title + 1 description line).**

**Format:**
```
PREFIX: Brief description of change

Single line explaining what was changed and why.
```

**Example:**
```
BUILD: Fix MSVC MSB8065 warnings for custom build outputs

Touch OUTPUT files on MSVC to satisfy MSBuild's requirement that custom command outputs must exist after execution.
```

**Note:** No Co-Authored-By or other trailing metadata in commit messages.

## Troubleshooting

### Fork Not Found Error

**Error:**
```
fatal: repository 'https://github.com/EricGT/<package>.git/' not found
```

**Cause:** The GitHub fork for this package doesn't exist yet.

**Solution:** Refer to the **Fork Setup** section in `/swipl-git-workflow` skill for detailed instructions on creating the fork before attempting to push or create a PR.
