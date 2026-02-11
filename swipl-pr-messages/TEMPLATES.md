# PR Templates by Category

All examples are derived from actual SWI-Prolog commits.

---

## FIXED: Bug Fixes

**Note:** Use `FIXED:` (past tense), not `FIX:` - this is the project convention.

### Simple Bug Fix

**Title:** `FIXED: Brief description of what was fixed`

**Body:** (can be empty if self-explanatory)

### Bug Fix with Context

**Title:** `FIXED: directory_member/3: respect file_type(regular) option`

**Body:**
```markdown
This allows 'directory_member/3' to generate regular (non-directory)
files with option 'file_type(regular)', in accordance with how
'absolute_file_name/3' treats this option.
```

### Bug Fix with Problem/Solution

**Title:** `FIXED: Missing semicolon in ssize_t typedef for MSVC`

**Body:**
```markdown
## Problem

Commit 9c474fa added `ssize_t` typedef for MSVC but was missing a semicolon on line 55, causing compilation errors:

    error C2054: expected '(' to follow 'ssize_t'

## Solution

- Added missing semicolon: `typedef intptr_t ssize_t;`
- Reordered typedef to come before `#define` macros to match SWI-Prolog convention

## Testing

- Built successfully with MSVC on Windows
- All clib tests pass
```

---

## ADDED: New Features

### Simple Addition

**Title:** `ADDED: predicate_name/arity description`

**Body:** (empty or brief)

### Addition with Explanation

**Title:** `ADDED: process_create/3: specify program as prolog(Tool)`

**Body:**
```markdown
This allows Prolog running one of its tools, with the guarantee that we
use the tools from the same version. This provides a hook prolog:prolog_tool/4
that allows embedded systems to redefine how the Prolog tools should be
executed.
```

### Addition with Discourse Link

**Title:** `ADDED: exported predicate for programmatic access to help`

**Body:**
```markdown
As mentioned on the Discourse: https://swi-prolog.discourse.group/t/programmatic-interface-to-library-help/9069/2
```

---

## ENHANCED: Improvements

### Simple Enhancement

**Title:** `ENHANCED: Brief description of improvement`

**Body:** (can be empty)

### Enhancement with Details

**Title:** `ENHANCED: Make rewrite_host/3 hook work for tcp_connect/3`

**Body:**
```markdown
Also allows tcp_connect/3 to accept an IP number. These two enhancements
avoid the need to lookup `localhost` on Windows.
```

### Enhancement with Multiple Changes

**Title:** `ENHANCED: re_config/1 backtracks through all possible values`

**Body:**
```markdown
- re_config/1 fails if an invalid option is given instead of throwing an error
- Fixed some PCRE1 vs PCRE2 documentation for re_config/1
- Added a test to check that re_config/1's documentation is a complete list
- Comparison now uses the pattern; blob-write also shows pattern

This is a follow-on to #15.
```

---

## MODIFIED: Behavior Changes

Use when changing existing behavior that isn't a bug fix.

### Simple Modification

**Title:** `MODIFIED: library(uri) to raise more exceptions and support URNs`

**Body:** (empty)

### Modification with Migration Note

**Title:** `MODIFIED: term_hash/2: extended range`

**Body:**
```markdown
As tagged integers now have the same range on all platforms, the
range for term_hash/2 has been extended to the max tagged integer.

You can get the old hash by masking the lower 24 bits.

BUG: The test values for big endian are not updated as I do not have access
to big endian hardware right now. Please submit the corrected values. See
`tests/core/test_hash.pl`.
```

---

## DOC: Documentation

### Simple Documentation Change

**Title:** `DOC: Brief description`

**Body:** (empty)

### Documentation with Discussion Link

**Title:** `DOC: Clarify the use of Key and Priority in library(heaps)`

**Body:**
```markdown
This was briefly discussed here: https://swi-prolog.discourse.group/t/is-the-documentation-of-library-heaps-confusing/9259

This only contains changes in the documentation strings.

- Changed all "Key" arguments to "Value" and all "Priority" arguments to "Key"
- Tagged a "very inefficient" warning as a bug
- Mentioned cyclic terms in passing
```

---

## PORT: Portability

### Simple Portability Fix

**Title:** `PORT: Brief description of platform fix`

**Body:** (can reference build log)

### Portability with Build Log

**Title:** `PORT: Replace sprintf by snprintf to avoid deprecation warnings`

**Body:**
```markdown
See build log: www.stats.ox.ac.uk/pub/bdr/M1-SAN/rswipl/00check.log
```

### Portability with Explanation

**Title:** `PORT: Ensure default 4Mb C-stack on Windows`

**Body:**
```markdown
Otherwise the default is 2Mb for MinGW and 1Mb for MSVC
```

### Windows/MSVC Portability

**Title:** `PORT: Fix FindPCRE.cmake for vcpkg debug/release libraries on Windows`

**Body:**
```markdown
When building on Windows with vcpkg, the PCRE package was linking against
the release library (pcre2-8.lib) even in Debug builds, causing the
vcpkg applocal script to fail copying the correct debug DLL (pcre2-8d.dll).

This fix uses CMake's SelectLibraryConfigurations module to properly
detect and use pcre2-8d for Debug builds and pcre2-8 for Release builds
on Windows, while maintaining existing behavior on other platforms.

Tested with Visual Studio 2026 and vcpkg on Windows 11.
```

---

## BUILD: Build System

### Simple Build Change

**Title:** `BUILD: Brief description`

**Body:** (empty)

### Build with Explanation

**Title:** `BUILD: Install pldoc/hooks.pl instead of the .qlf file`

**Body:**
```markdown
This is an include file that is used by the web server to customise PlDoc.
```

---

## TEST: Testing

### Simple Test Change

**Title:** `TEST: Brief description`

**Body:** (empty)

### Test with Platform Note

**Title:** `TEST: term_hash/2 for indirect data types (bigints, floats)`

**Body:**
```markdown
term_hash/2 is platform dependent as it hashes the binary representations
of _indirect types_ (big int, rational, float). The test succeeds if the
produced hash is one of a set. When using LibBF, the hash also depends on
whether the _limb size_ is 32 bits or 64 bits.
```

---

## CLEANUP: Code Cleanup

### Simple Cleanup

**Title:** `CLEANUP: Brief description`

**Body:** (empty or brief)

### Cleanup with Reason

**Title:** `CLEANUP: Use unsigned integers for bitmaps`

**Body:**
```markdown
Avoids undefined shifts and makes the code more readable.
```

### Cleanup Warning Fix

**Title:** `CLEANUP: Avoid reading uninitialized local variable`

**Body:**
```markdown
Not entirely sure why the popSegStack() can fail. Surely it does on the
XSB tests from `tests/xsb/sub_tests/xsb_test_sub.pl`. In debug mode we
set `dstate` such that accessing it crashes.
```

---

## COMPAT: Compatibility

### API Compatibility

**Title:** `COMPAT: Use new PL_dispatch() API`

**Body:** (empty)

### Backwards Compatibility

**Title:** `COMPAT: Support both old and new abort exception`

**Body:** (empty)

---

## WASM: WebAssembly

### Simple WASM Change

**Title:** `WASM: Brief description`

**Body:** (empty)

### WASM Feature

**Title:** `WASM: Added Prolog.__with_stack_strings()`

**Body:**
```markdown
This interface allows for cleanup of temporary strings. It provides
a WASM version of `PL_STRINGS_MARK() ... PL_STRINGS_RELEASE()`
```

---

## Tips for Good PR Messages

1. **Use `FIXED:` not `FIX:`** - Project convention is past tense
2. **Link context** - Reference Discourse discussions, issues, or related commits
3. **Be specific** - Include error messages, affected platforms, predicate names
4. **Keep it brief** - Empty body is fine for obvious changes
5. **Use sections** - For complex changes: Problem/Solution/Testing/Related
6. **Mention testing** - What was tested and on which platforms
7. **Reference patterns** - Point to existing code that follows the same convention
