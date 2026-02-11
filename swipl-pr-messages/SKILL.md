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

Before creating a PR, check the diff for `.gitignore` file changes:

1. Run `git diff <base>..HEAD -- .gitignore **/.gitignore` (or inspect the staged/committed changes) to see if any `.gitignore` files are modified.
2. If `.gitignore` changes are present, **stop and ask the user** whether the `.gitignore` change should be included in the PR. Show them the specific `.gitignore` diff so they can decide.
3. If the user says to remove it, unstage or revert the `.gitignore` change before creating the PR (e.g., `git checkout <base> -- .gitignore` and amend/recommit).

This prevents accidentally sending local `.gitignore` preferences upstream.

## Body Formats

**See [TEMPLATES.md](TEMPLATES.md) for detailed templates by category.**

### Minimal Body

For self-explanatory changes, the body can be brief or reference external discussion:

```markdown
Brief explanation of what was changed and why.
```

Or just link to discussion:

```markdown
See discussion: https://swi-prolog.discourse.group/t/topic-slug/1234
```

### Structured Body

For complex changes, use sections:

```markdown
## Problem

Brief description of the issue being fixed.

## Solution

- What was changed
- Why this approach was chosen

## Testing

- How it was tested
- Which platforms/configurations

## Related

Link to related issues, PRs, or Discourse discussions.
```

## Real Examples from SWI-Prolog

### FIXED: Bug Fix

**Title:** `FIXED: crypt/2 on Windows using bsd-crypt.c: possible memory corruption`

**Body:** (minimal - self-explanatory from title)

### ADDED: New Feature

**Title:** `ADDED: process_create/3: specify program as prolog(Tool)`

**Body:**
```markdown
This allows Prolog running one of its tools, with the guarantee that we
use the tools from the same version. This provides a hook prolog:prolog_tool/4
that allows embedded systems to redefine how the Prolog tools should be
executed.
```

### ENHANCED: Improvement

**Title:** `ENHANCED: Make rewrite_host/3 hook work for tcp_connect/3`

**Body:**
```markdown
Also allows tcp_connect/3 to accept an IP number. These two enhancements
avoid the need to lookup `localhost` on Windows.
```

### MODIFIED: Behavior Change

**Title:** `MODIFIED: library(uri) to raise more exceptions and support URNs`

**Body:** (empty - change is clear from title)

### PORT: Portability

**Title:** `PORT: Ensure default 4Mb C-stack on Windows`

**Body:**
```markdown
Otherwise the default is 2Mb for MinGW and 1Mb for MSVC
```

### DOC: Documentation

**Title:** `DOC: thread_property/2 did not document the debug property`

**Body:** (empty)

### CLEANUP: Code Cleanup

**Title:** `CLEANUP: Use unsigned integers for bitmaps`

**Body:**
```markdown
Avoids undefined shifts and makes the code more readable.
```

### BUILD: Build System

**Title:** `BUILD: replace CMake deprecated exec_program() with execute_process()`

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

When the PR has a single commit, the commit message should align with the PR:

**Headline:** Brief description (may omit prefix)
**Body:** Detailed technical explanation

```
Fix missing semicolon and improve typedef placement

Jan's commit 9c474fa added ssize_t typedef for MSVC but was missing
a semicolon, causing compilation errors. Also reordered to match
SWI-Prolog convention where typedefs come before #define macros.

Changes:
- Added missing semicolon: typedef intptr_t ssize_t;
- Moved typedef before #define read/_read and fileno/_fileno
- Matches pattern in src/os/windows/uxnt.h and src/os/SWI-Stream.h
```
