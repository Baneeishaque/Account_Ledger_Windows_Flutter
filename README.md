# account_ledger_windows

Account Ledger Windows Desktop App.

## Development Setup

This project uses [mise](https://mise.jdx.dev/) for managing tool versions, including Flutter via [aqua](https://aquaproj.github.io/).

### Prerequisites

1. Install mise: Follow the [official installation guide](https://mise.jdx.dev/getting-started.html)

### Quick Start

1. Clone the repository with submodules:
   ```bash
   git clone --recursive https://github.com/Baneeishaque/Account_Ledger_Windows_Flutter.git
   cd Account_Ledger_Windows_Flutter
   ```

2. Install project dependencies (Flutter, Java, etc.):
   ```bash
   mise install
   ```
   This will automatically install Flutter via aqua and other required tools as specified in `mise.toml`.

3. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

4. Generate environment variables:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Flutter Version Management

This project uses Flutter via aqua through mise, which provides:
- **Cross-platform consistency**: Same setup works on Linux, macOS, and Windows
- **Version pinning**: Exact Flutter version specified in `mise.toml`
- **Easy upgrades**: Update version in one place (`mise.toml`)
- **Better CI/CD integration**: Simplified workflows without platform-specific workarounds

The Flutter version is managed in `mise.toml`:
```toml
[tools]
flutter = "aqua:flutter/flutter@3.19.6"
```

To upgrade Flutter, update the version in `mise.toml` and run `mise install`.

### Building

- **Linux**: `flutter build linux --release`
- **Windows**: `flutter build windows --release`

### Migration Notes

**Previous Setup (before aqua integration)**:
- Linux: Used mise with direct Flutter backend
- Windows: Required vfox workaround due to mise backend limitations

**Current Setup (with aqua)**:
- All platforms: Use mise with aqua backend for Flutter
- Simplified CI workflows with no platform-specific workarounds
- More reliable version management across different environments
