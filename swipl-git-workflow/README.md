# SWI-Prolog Git Workflow Skill - Quick Reference

A Claude Code skill for streamlined git operations in the SWI-Prolog PR development environment.

## Installation

The skill is project-specific and located at:
```
<YOUR_PROJECT_ROOT>\.claude\skills\swipl-git-workflow\
```

It's automatically available when working in the SWI-Prolog PR project.

## Quick Usage

Invoke with: `/swipl-git-workflow <operation> [args]`

### Common Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `status` | Check git status across all repos | `/swipl-git-workflow status` |
| `branch <name>` | Create feature branch | `/swipl-git-workflow branch fix-socket-bug` |
| `push` | Push current branch to fork | `/swipl-git-workflow push` |
| `pr` | Create pull request to upstream | `/swipl-git-workflow pr` |
| `sync` | Sync master with upstream (reset, NO merge) | `/swipl-git-workflow sync` |
| `sync all` | Sync all repos with upstream | `/swipl-git-workflow sync all` |
| `update` | Update feature branch (rebase, NO merge) | `/swipl-git-workflow update` |
| `which-package` | Identify current package | `/swipl-git-workflow which-package` |

## Typical Workflow

```bash
# 1. Check status
/swipl-git-workflow status

# 2. Create feature branch
/swipl-git-workflow branch fix-msvc-warning

# 3. Make changes and commit
git add file.c
git commit -m "FIXED: MSVC warning in socket handling"

# 4. Push to your fork
/swipl-git-workflow push

# 5. Create PR to upstream
/swipl-git-workflow pr
```

## Key Features

### Clean PR Workflow (MANDATORY)
**Per Jan's requirement:** No merge commits in PRs - they make review confusing.

- ✅ Use `git reset --hard upstream/master` to sync master branch
- ✅ Use `git rebase upstream/master` to update feature branches
- ✅ Use `git merge` for local integration testing only (never pushed)
- ❌ NEVER use `git merge upstream/master` in PR branches

This keeps PR history linear and easy to review.

### Multi-Repository Awareness
- Automatically detects which repository/package you're in
- Handles main repo and all 10 forked packages
- Supports nested submodule (winlibedit)

### Branch-First Enforcement
- Ensures you create a feature branch before changes
- Prevents accidental commits to master
- Suggests branch names based on task

### Fork Management
- Origin → Your fork (`<YOUR_GITHUB_USER>/*`)
- Upstream → Official (SWI-Prolog/*)
- Automatic repository mapping for PRs

### Integration Testing
- Pattern for testing multiple fixes together
- Keep PRs independent while testing combined
- No mixing of unrelated changes

## Repository Structure

**Forked packages** (accept PRs):
- packages-bdb
- packages-clib
- packages-cpp
- packages-jpl
- packages-libedit
- packages-nlp
- packages-pcre
- packages-semweb
- packages-xpce
- winlibedit (nested in libedit)

**Other packages**: Use upstream URLs only

## Integration with Other Skills

### With `/swipl-pr-messages`

The PR creation flow automatically invokes the `swipl-pr-messages` skill to format:
- PR title with proper prefix (FIXED:, ADDED:, etc.)
- PR body with sections (Summary, Files Changed, Test Plan)
- Commit message format

Example flow:
```bash
/swipl-git-workflow pr
# → Invokes /swipl-pr-messages for title/body
# → Checks for .gitignore changes
# → Creates PR with gh CLI
```

## Files

- **SKILL.md** - Main skill definition and documentation
- **EXAMPLES.md** - Detailed implementation examples and bash scripts
- **README.md** - This quick reference

## Advanced Patterns

### Testing Multiple Fixes Together

```bash
# Create integration branch
cd packages/clib
git checkout master
git checkout -b test-all-20260211

# Merge all feature branches
git merge fix-socket-warning
git merge add-ipv6-support
git merge enhance-errors

# Build and test combined changes
cmake --build ../../build --config Debug
ctest -C Debug --output-on-failure

# Create PRs from individual branches (not integration branch)
git checkout fix-socket-warning
/swipl-git-workflow pr
```

### Syncing Before Starting Work

```bash
# Sync everything
/swipl-git-workflow sync all

# Or sync just one package
cd packages/clib
/swipl-git-workflow sync
```

### Working Across Packages

```bash
# Check where you are
/swipl-git-workflow which-package

# See status everywhere
/swipl-git-workflow status

# Each package is independent
cd packages/clib
git branch --show-current  # may be on fix-clib-bug

cd ../pcre
git branch --show-current  # may be on fix-pcre-regex
```

## Notes

- **MANDATORY:** No merge commits in PRs - use reset for master, rebase for feature branches
- **MANDATORY:** Master branch is sacred - never commit directly to it
- Always use Git Bash for consistency
- Use `--force-with-lease` (not `--force`) when force-pushing after rebase
- PR bodies auto-include: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`
- .gitignore changes trigger warnings before PR creation

## See Also

- `/swipl-pr-messages` - PR title and body formatting
- `CLAUDE.md` - Project documentation
- `MEMORY.md` - Branch workflow patterns and resolved issues
