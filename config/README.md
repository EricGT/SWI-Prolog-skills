# Configuration Guide

This directory contains scripts and templates for configuring the SWI-Prolog PR workflow for any Windows 11 user.

## Quick Start

### 1. Run Setup Environment Script

```powershell
cd C:\Users\YourName\Projects\your-swipl-pr\.claude\skills\config
. .\setup-environment.ps1
```

This script will:
- **Auto-detect** your installed tools (Python, SWI-Prolog, vcpkg, Visual Studio)
- **Set environment variables** for the current PowerShell session
- **Validate** that all required paths are configured correctly
- **Display** a summary of your environment

### 2. (Optional) Create a Persistent Configuration

If you want environment variables to persist across sessions:

1. **Copy the template:**
   ```powershell
   Copy-Item config.template.json config.json
   ```

2. **Edit `config.json`** with your paths

3. **Add to PowerShell profile** (optional):
   ```powershell
   # In your $PROFILE file, add:
   . "$PSScriptRoot\config\setup-environment.ps1"
   ```

## Environment Variables

The setup script configures these environment variables:

### Required (Must Exist)

| Variable | Purpose | Auto-Detection |
|----------|---------|-----------------|
| `SWIPL_SOURCE_DIR` | SWI-Prolog source repository | Searches for `.git` + `CMakeLists.txt` |
| `VCPKG_ROOT` | vcpkg installation | Looks for `vcpkg.exe` in common locations |
| `PYTHON_ROOT` | Python installation root | Uses `python -c "import sys; print(sys.prefix)"` |

### Optional (Recommended)

| Variable | Purpose | Auto-Detection |
|----------|---------|-----------------|
| `SWIPL_PROJECT_ROOT` | Your project root | Looks for `CLAUDE.md` in parent directories |
| `SWIPL_HOME` | SWI-Prolog bin directory | Searches PATH for `swipl.exe` |
| `GITHUB_USER` | GitHub username | Reads from `git config github.user` or `user.name` |

### Derived (Computed Automatically)

| Variable | Purpose |
|----------|---------|
| `SWIPL_OUTPUT_DIR` | Build logs directory: `{SWIPL_PROJECT_ROOT}\output` |
| `SWIPL_BUILD_DIR` | CMake build directory: `{SWIPL_SOURCE_DIR}\build` |

## Manual Configuration

If auto-detection fails, set environment variables manually:

```powershell
$env:SWIPL_SOURCE_DIR = "C:\path\to\swipl-devel"
$env:SWIPL_PROJECT_ROOT = "C:\path\to\your-project"
$env:VCPKG_ROOT = "C:\path\to\vcpkg"
$env:PYTHON_ROOT = "C:\Python313"
$env:GITHUB_USER = "your-username"
```

## Troubleshooting

### Auto-Detection Issues

**Problem: SWIPL_SOURCE_DIR not found**
```
Solution: Set manually: $env:SWIPL_SOURCE_DIR = "C:\dev-MSVC-PR\swipl-devel"
```

**Problem: VCPKG_ROOT not found**
```
Solution: Install vcpkg or set: $env:VCPKG_ROOT = "C:\vcpkg"
```

**Problem: Python not found**
```
Solution: Install Python or set: $env:PYTHON_ROOT = "C:\Python313"
```

**Problem: Git config not working**
```
Solution: Configure git:
  git config --global github.user "your-username"
  git config --global user.name "Your Name"
```

### Script Fails to Run

```powershell
# If you get permission errors:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify script syntax:
powershell -NoProfile -File setup-environment.ps1
```

### Validation Errors

After running the script, check the validation output:

- **[OK]** - Path exists and is valid
- **[WARN]** - Optional variable not set (may not be needed)
- **[ERROR]** - Required path missing (needs to be fixed)

Fix any [ERROR] messages before using the workflow scripts.

## Multiple User Setup

Each user should run setup independently:

1. **User 1:**
   ```powershell
   . .\setup-environment.ps1
   # Sets SWIPL_SOURCE_DIR=C:\dev\swipl-devel, etc. for User 1
   ```

2. **User 2:**
   ```powershell
   . .\setup-environment.ps1
   # Auto-detects User 2's install paths
   # Sets SWIPL_SOURCE_DIR=D:\Projects\swipl-devel, etc. for User 2
   ```

No manual editing needed - each user gets their own paths.

## Advanced: Using with Automation

For automation scripts that need configuration:

```powershell
# Source configuration
$configScript = Join-Path $PSScriptRoot "..\config\setup-environment.ps1"
. $configScript

# Now use the environment variables
Write-Host "Building in: $env:SWIPL_SOURCE_DIR"
```

## Files in This Directory

| File | Purpose |
|------|---------|
| `setup-environment.ps1` | Main configuration script - auto-detects and validates paths |
| `config.template.json` | Configuration template (reference only) |
| `README.md` | This file |

## Related Scripts

After configuring, you can use these scripts (in parent directories):

- `..\..\scripts\setup-wizard.ps1` - Interactive first-time setup
- `..\..\scripts\build\build-msvc.ps1` - Build SWI-Prolog
- `..\..\scripts\pr\*.ps1` - PR workflow scripts

## Support

For issues with the configuration system:

1. Check the troubleshooting section above
2. Review error messages from `setup-environment.ps1`
3. Verify all required software is installed:
   - Visual Studio 2022+ (for C++ development)
   - Python 3.12+ (for build scripts)
   - SWI-Prolog 10.0+ (for testing)
   - vcpkg (for dependencies)

## Notes

- Configuration applies only to current PowerShell session
- To make it permanent, add to your PowerShell profile
- Different users can have different paths - no conflicts
- All paths are normalized automatically by scripts
- Environment variable expansion happens at script runtime (visible in logs)
