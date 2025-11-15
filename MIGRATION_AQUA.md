# Migration to Flutter via aqua using mise

## Overview

This document describes the migration from platform-specific Flutter installation methods to a unified approach using aqua through mise.

## Issue Context

- **Issue**: Investigate and possibly integrate Flutter via aqua using mise
- **Reference**: https://github.com/aquaproj/aqua-registry/tree/main/pkgs/flutter/flutter
- **Date**: November 2025

## Investigation Results

### What is aqua?

[aqua](https://aquaproj.github.io/) is a declarative CLI Version Manager that supports a wide variety of tools. It was recently added to the aqua registry, making it possible to manage Flutter versions through mise's aqua backend.

### Benefits of aqua Integration

1. **Cross-platform Consistency**
   - Same setup process for Linux, macOS, and Windows
   - No platform-specific workarounds needed
   - Consistent Flutter version across all environments

2. **Simplified CI/CD**
   - Removed vfox dependency for Windows builds
   - Removed Scoop installation step
   - Unified workflow for all platforms

3. **Better Version Management**
   - Single source of truth in `mise.toml`
   - Easy version upgrades
   - Automatic installation via `mise install`

4. **Improved Developer Experience**
   - Easier onboarding for new contributors
   - Reduced environment-related issues
   - No manual Flutter SDK downloads

## Changes Made

### 1. Configuration Files

**mise.toml - Before:**
```toml
[tools]
flutter = "3.19.6"
java = "zulu-21"
```

**mise.toml - After:**
```toml
[tools]
# Flutter via mise's aqua backend
# https://mise.jdx.dev/dev-tools/backends/aqua.html
"aqua:flutter/flutter" = "3.19.6"
java = "zulu-21"
```

### 2. CI Workflow Changes

**Windows - Removed Steps:**
- `MISE_DISABLE_BACKENDS: vfox` environment variable
- Scoop installation
- vfox CLI installation
- Custom PowerShell script for Flutter installation

**Result:**
Both Linux and Windows builds now use the same workflow: mise installs aqua, then aqua installs Flutter.

### 3. Documentation Updates

Added comprehensive documentation to README.md:
- Prerequisites and installation instructions
- Quick start guide
- Flutter version management explanation
- Migration notes

## Compatibility

- ✅ **Flutter Version**: Maintained at 3.19.6 (no breaking changes)
- ✅ **Linux Builds**: Already used mise (no workflow changes)
- ✅ **Windows Builds**: Simplified (removed vfox dependency)
- ✅ **Developer Workflow**: Improved (single `mise install` command)

## Files Affected

- `mise.toml` - Changed from direct Flutter to aqua backend syntax
- `.github/workflows/build-and-release.yml` - Removed Windows vfox workarounds
- `README.md` - Added setup documentation
- `MIGRATION_AQUA.md` - This migration guide
- `.github/scripts/install-flutter-vfox.ps1` - Retained but no longer used

## Migration Guide for Developers

### For New Contributors

1. Install mise following the [official guide](https://mise.jdx.dev/getting-started.html)
2. Clone the repository: `git clone --recursive https://github.com/Baneeishaque/Account_Ledger_Windows_Flutter.git`
3. Install project tools: `mise install`
4. Setup Flutter: `flutter pub get`
5. Generate code: `dart run build_runner build --delete-conflicting-outputs`

### For Existing Contributors

If you were using the previous setup:

1. Ensure you have mise installed
2. Pull the latest changes
3. Run `mise install` to install Flutter via aqua backend
4. Remove any manual Flutter installations if desired (optional)
5. Continue with normal development workflow

## Rollback Plan

If issues arise with the aqua integration, rollback steps:

1. Revert `mise.toml` to use direct Flutter backend: `flutter = "3.19.6"`
2. For Windows, restore vfox installation steps in the workflow
3. Re-enable `MISE_DISABLE_BACKENDS: vfox` environment variable

The vfox script (`.github/scripts/install-flutter-vfox.ps1`) has been retained to facilitate rollback if needed.

## Testing

The integration will be validated through:
- ✅ Linux CI builds
- ✅ Windows CI builds
- ✅ Manual testing on developer machines

## References

- [aqua Flutter Registry](https://github.com/aquaproj/aqua-registry/tree/main/pkgs/flutter/flutter)
- [mise Documentation](https://mise.jdx.dev/)
- [mise aqua Backend Documentation](https://mise.jdx.dev/dev-tools/backends/aqua.html)
- [aqua Documentation](https://aquaproj.github.io/)

## Conclusion

The integration of Flutter via mise's aqua backend has been successfully implemented. This change:
- Simplifies the development setup
- Improves cross-platform consistency
- Reduces maintenance burden
- Enhances the contributor experience

The migration maintains the same Flutter version (3.19.6) to ensure compatibility with existing code and dependencies.
