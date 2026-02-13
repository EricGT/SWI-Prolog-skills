# SWI-Prolog Skills for Claude Code

A collection of [Claude Code](https://claude.com/claude-code) skills designed specifically for SWI-Prolog development and pull request workflows.

## Overview

These skills streamline the development workflow for contributing to [SWI-Prolog](https://www.swi-prolog.org/) and its packages. They handle the complexity of working with multiple forked repositories, enforce best practices for clean PR history, and automate common git operations.

## Skills

### 1. `swipl-git-workflow`

**Description:** Git workflow commands for SWI-Prolog PR development with forked repositories and submodules.

**Features:**
- Multi-repository status checks across main repo and 10 forked packages
- Branch creation with branch-first enforcement
- Push to fork with proper tracking
- PR creation with automatic repository mapping
- Master sync using `reset --hard` (NO merge commits per project requirements)
- Feature branch updates using `rebase` (NO merge commits)
- Integration testing pattern for multiple fixes

**Quick Start:**
```bash
/swipl-git-workflow status           # Check all repositories
/swipl-git-workflow branch fix-bug   # Create feature branch
/swipl-git-workflow push             # Push to your fork
/swipl-git-workflow pr               # Create pull request
```

[Full Documentation →](swipl-git-workflow/SKILL.md)

### 2. `swipl-build`

**Description:** Build and test SWI-Prolog with MSVC on Windows. Provides dry-run preview mode to preview build steps before executing. Automates MSVC environment setup, CMake configuration, compilation, and testing across Release, Debug, RelWithDebInfo, MinSizeRel, and Sanitize configurations.

**Features:**
- **Dry-run preview** - See full build plan before executing (default mode)
- Multi-configuration support (Release, Debug, RelWithDebInfo, MinSizeRel, Sanitize)
- Automatic MSVC environment initialization
- Windows reserved device name handling (nul, con, prn)
- Timestamped log files for each phase
- Python and tool availability checking
- Full test suite execution with timeout management

**Quick Start:**
```bash
/swipl-build build Release              # Preview Release build
/swipl-build build Release -execute     # Actually execute the build
/swipl-build test Debug                 # Test Debug configuration
/swipl-build clean                      # Clean build directory
```

[Full Documentation →](swipl-build/SKILL.md)

### 3. `swipl-pr-messages`

**Description:** Generate properly formatted SWI-Prolog pull request titles and body messages following project conventions.

**Features:**
- Standard PR title prefixes (FIXED:, ADDED:, ENHANCED:, PORT:, etc.)
- Multiple body templates for different change types
- `.gitignore` change detection and warnings
- Discourse integration links
- Commit message formatting

**Quick Start:**
```bash
/swipl-pr-messages    # Analyze changes and generate PR title/body
```

**Title Prefixes:**
- `FIXED:` - Bug fixes
- `ADDED:` - New features
- `ENHANCED:` - Improvements
- `PORT:` - Portability fixes
- `DOC:` - Documentation
- `BUILD:` - Build system changes
- And more...

[Full Documentation →](swipl-pr-messages/SKILL.md)

## Installation

### For SWI-Prolog PR Development

These skills are automatically available when working in a properly configured SWI-Prolog PR development project with the following structure:

```
your-project/
└── .claude/
    └── skills/
        ├── swipl-git-workflow/
        └── swipl-pr-messages/
```

### For Other Projects

To use these skills in your own project:

1. Clone this repository:
   ```bash
   git clone https://github.com/EricGT/SWI-Prolog-skills.git
   ```

2. Copy the desired skills to your project's `.claude/skills/` directory:
   ```bash
   mkdir -p your-project/.claude/skills
   cp -r SWI-Prolog-skills/swipl-git-workflow your-project/.claude/skills/
   cp -r SWI-Prolog-skills/swipl-pr-messages your-project/.claude/skills/
   ```

3. The skills will be automatically detected by Claude Code when you work in that project.

## Usage Examples

### Complete PR Workflow

```bash
# 1. Sync with upstream
/swipl-git-workflow sync all

# 2. Create feature branch
cd packages/clib
/swipl-git-workflow branch fix-socket-timeout

# 3. Make your changes
# Edit files...
git add socket.c
git commit -m "FIXED: Socket timeout handling on Windows"

# 4. Push to your fork
/swipl-git-workflow push

# 5. Create pull request
/swipl-git-workflow pr
# This automatically invokes swipl-pr-messages for formatting
```

### Testing Multiple Fixes Together

```bash
# Create local integration branch
cd packages/clib
git checkout master
git checkout -b test-all-fixes-20260211

# Merge all fixes (OK - this branch never becomes a PR)
git merge fix-socket-timeout
git merge add-ipv6-support
git merge enhance-error-messages

# Build and test
cmake --build ../../build --config Debug
ctest -C Debug --output-on-failure

# Create separate PRs from original branches
git checkout fix-socket-timeout
/swipl-git-workflow pr

git checkout add-ipv6-support
/swipl-git-workflow pr
```

### Updating Feature Branch

```bash
# When your feature branch is behind upstream
cd packages/pcre
git checkout fix-unicode-bug

# Rebase onto latest upstream (NO merge)
/swipl-git-workflow update

# Force-push to your fork
git push origin fix-unicode-bug --force-with-lease
```

## Key Concepts

### Clean PR Philosophy

SWI-Prolog maintainers require **clean PR history without merge commits**.

**Rules:**
- ✅ **DO** use `git reset --hard upstream/master` to sync master
- ✅ **DO** use `git rebase upstream/master` to update feature branches
- ✅ **DO** use `git merge` for local integration testing (never pushed)
- ❌ **DON'T** use `git merge upstream/master` in PR branches
- ❌ **DON'T** create merge commits that will become part of PRs

**Why?** Merge commits in PR branches make the history confusing to review. Using reset and rebase keeps history linear and clear.

### Branch-First Rule

**MANDATORY:** Never make code changes directly on `master`.

Before editing any source file:
1. Verify you're on a dedicated feature branch
2. If no branch exists, create one: `/swipl-git-workflow branch <name>`
3. Only proceed with code edits after confirming correct branch

### Repository Structure

The SWI-Prolog project uses a main repository with multiple submodules. These skills handle:

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

### Remote Configuration

All forked repositories use this structure:
- `origin` → Your fork (e.g., EricGT/packages-clib)
- `upstream` → Official SWI-Prolog repository

Push to `origin`, create PRs to `upstream`.

## Skill Integration

The skills work together seamlessly:

- `/swipl-git-workflow pr` automatically invokes `/swipl-pr-messages` to generate properly formatted PR titles and bodies
- Both skills check for `.gitignore` changes and warn before creating PRs
- PR bodies automatically include: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI tool
- Git (Git Bash recommended for Windows)
- [GitHub CLI](https://cli.github.com/) (`gh`) for PR creation
- Properly configured fork/upstream remotes

## Documentation

Each skill includes comprehensive documentation:

- **SKILL.md** - Full skill definition and detailed documentation
- **README.md** - Quick reference guide
- **EXAMPLES.md** (where applicable) - Implementation examples and scripts
- **TEMPLATES.md** (where applicable) - Templates and formatting guides

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Resources

- [SWI-Prolog](https://www.swi-prolog.org/) - Official website
- [SWI-Prolog GitHub](https://github.com/SWI-Prolog/swipl-devel) - Main repository
- [SWI-Prolog Discourse](https://swi-prolog.discourse.group/) - Community forum
- [Claude Code](https://claude.com/claude-code) - AI-powered coding assistant
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk) - Build custom agents

## Acknowledgments

These skills were developed to streamline contributions to SWI-Prolog, following the project's conventions and requirements for clean PR history.

Special thanks to the SWI-Prolog maintainers for their guidance on proper PR workflows.

---

**Created with [Claude Code](https://claude.com/claude-code)** 🤖
