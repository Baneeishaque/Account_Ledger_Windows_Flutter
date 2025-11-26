# Account Ledger Desktop

<div align="center">

[![Build and Release Flutter App](https://github.com/Baneeishaque/Account_Ledger_Desktop_Flutter/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/Baneeishaque/Account_Ledger_Desktop_Flutter/actions/workflows/build-and-release.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.6-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Kotlin/Native](https://img.shields.io/badge/Kotlin%2FNative-Multiplatform-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org/docs/native-overview.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**A cross-platform desktop application for managing financial transactions and account ledgers built with Flutter and Kotlin/Native.**

[Features](#-features) • [Installation](#-installation) • [Development](#-development) • [Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Development](#-development)
- [Building](#-building)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Technologies](#-technologies)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

Account Ledger Desktop is a sophisticated financial management application designed for tracking transactions across multiple accounts. It provides an intuitive interface for managing financial ledgers with support for various transaction modes including normal transactions, two-way transactions, and complex multi-account transaction chains.

### Key Highlights

- 🖥️ **Cross-Platform**: Runs on Windows, Linux, and macOS
- 🔗 **API Integration**: Seamless GitHub Gist integration for data synchronization
- 🔊 **Audio Feedback**: Sound feedback for transaction operations
- 🎨 **Material Design 3**: Modern UI with Material You design language
- ⚡ **Native Performance**: Kotlin/Native backend for optimal performance

---

## ✨ Features

### Transaction Management
- **Normal Transactions**: Standard single transaction entries
- **Two-Way Transactions**: Bidirectional transaction recording
- **Multi-Account Transactions**: Support for complex transaction patterns:
  - `1→2, 3→1`: Three-account linked transactions
  - `1→2, 2→3 (Via)`: Via account transactions
  - `1→2, 2→3, 3→4`: Four-account chain transactions
  - `1→2, 2→3, 4→1`: Cyclic four-account transactions
  - `1→2, 2→3, 3→4, 4→1`: Complete four-account cycle

### Data Management
- GitHub Gist-based data synchronization
- Account relationship tracking
- Transaction date and time management
- Automatic event time incrementing on successful transactions

### User Experience
- Real-time form validation with toast notifications
- Audio feedback on transaction completion
- Dropdown search for transaction mode selection
- Processing state indicators

---

## 🏗️ Architecture

The application follows a hybrid architecture combining Flutter for the UI layer and Kotlin/Native for native platform-specific operations.

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  main.dart (App Entry & UI Components)              │   │
│  │  widget_helpers.dart (Custom Widget Builders)       │   │
│  │  common_widget_helpers.dart (Reusable Widgets)      │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                   Platform Channel Layer                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  account_ledger_kotlin_native_library_operations.dart│   │
│  │  (MethodChannel communication with native code)     │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                     Shared Libraries                        │
│  ┌──────────────────────┐  ┌────────────────────────────┐  │
│  │ account_ledger_      │  │ account_ledger_lib_        │  │
│  │ library_dart         │  │ kotlin_native              │  │
│  │ (Dart Library)       │  │ (Kotlin/Native Library)    │  │
│  └──────────────────────┘  └────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Component Description

| Component | Description |
|-----------|-------------|
| **Flutter UI** | Material Design 3 based user interface |
| **Platform Channel** | MethodChannel for native code communication |
| **Dart Library** | Business logic, models, and API operations |
| **Kotlin/Native** | Native library for platform-specific operations |

---

## 📦 Prerequisites

### System Requirements

| Platform | Requirements |
|----------|--------------|
| **Windows** | Windows 10 or later, Visual Studio 2019+ with C++ workload |
| **Linux** | Ubuntu 20.04+ or equivalent, GTK 3.0+, GStreamer |
| **macOS** | macOS 11.0+ (Big Sur), Xcode 12+ |

### Development Tools

- **Flutter SDK**: 3.19.6 or compatible version
- **Java JDK**: Zulu JDK 21 (recommended)
- **Git**: For version control and submodule management
- **mise** (optional): For managing tool versions

### Platform-Specific Dependencies

<details>
<summary><b>Linux Dependencies</b></summary>

```bash
sudo apt-get update
sudo apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    libstdc++-12-dev \
    libupower-glib-dev \
    libgstreamer1.0-dev \
    gstreamer1.0-plugins-base \
    libgstreamer-plugins-base1.0-dev
```

Or run the provided script:
```bash
./linux/installRquirementsUbuntu.bash
```

</details>

<details>
<summary><b>Windows Dependencies</b></summary>

- Visual Studio 2019 or later with:
  - "Desktop development with C++" workload
  - Windows 10 SDK
- PowerShell 5.1+

</details>

<details>
<summary><b>macOS Dependencies</b></summary>

- Xcode 12 or later
- Command Line Tools for Xcode
- CocoaPods (`sudo gem install cocoapods`)

</details>

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone --recursive https://github.com/Baneeishaque/Account_Ledger_Desktop_Flutter.git
cd Account_Ledger_Desktop_Flutter
```

If you've already cloned without submodules:
```bash
git submodule update --init --recursive
```

### 2. Install Flutter SDK

Using mise (recommended):
```bash
mise install
```

Or manually install Flutter 3.19.6 from [flutter.dev](https://flutter.dev/docs/get-started/install).

### 3. Set Up Environment Variables

Create a `.env` file in the project root based on the sample:

```bash
cp .env_sample .env
```

Edit `.env` with your configuration:
```env
USER_NAME=your_username
GITHUB_TOKEN=your_github_personal_access_token
GIST_ID=your_gist_id
USER_ID=your_user_id
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Generate Environment Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🛠️ Development

### Running in Development Mode

```bash
# Linux
flutter run -d linux

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

### Hot Reload

Flutter supports hot reload for rapid development. Press `r` in the terminal or save a file to trigger hot reload.

### Code Analysis

Run the Dart analyzer:
```bash
flutter analyze
```

### Code Formatting

```bash
dart format lib/
```

### Generating Environment Files

After modifying `lib/env/env.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🔨 Building

### Build for Linux

```bash
# Build Kotlin/Native library
cd account_ledger_lib_kotlin_native
./gradlew linkDebugSharedLinuxX64
cd ..

# Build Flutter app
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

### Build for Windows

```bash
# Build Kotlin/Native library
cd account_ledger_lib_kotlin_native
./gradlew.bat linkDebugSharedMingwX64
cd ..

# Build Flutter app
flutter build windows --release
```

Output: `build/windows/runner/Release/`

### Build for macOS

```bash
# Build Kotlin/Native library
cd account_ledger_lib_kotlin_native
./gradlew linkReleaseSharedMacosArm64
cd ..

# Build Flutter app
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/`

### CI/CD

The project uses GitHub Actions for automated builds. See `.github/workflows/build-and-release.yml` for the complete CI/CD configuration.

---

## 📁 Project Structure

```
Account_Ledger_Desktop_Flutter/
├── .github/
│   ├── actions/           # Reusable GitHub Actions
│   │   ├── clone-env/
│   │   ├── flutter-app-build/
│   │   ├── flutter-setup/
│   │   ├── install-jq/
│   │   ├── kotlin-native-build/
│   │   ├── setup-mise/
│   │   └── upload-artifact/
│   ├── scripts/           # Build scripts
│   └── workflows/         # CI/CD workflows
├── account_ledger_lib_kotlin_native/  # Kotlin/Native library (submodule)
├── account_ledger_library_dart/       # Dart library (submodule)
├── assets/                # Application assets
│   └── button.wav         # Audio feedback file
├── lib/                   # Flutter application source
│   ├── env/
│   │   └── env.dart       # Environment configuration
│   ├── account_ledger_kotlin_native_library_operations.dart
│   ├── common_widget_helpers.dart
│   ├── main.dart          # Application entry point
│   └── widget_helpers.dart
├── linux/                 # Linux platform files
├── macos/                 # macOS platform files
├── windows/               # Windows platform files
├── .env_sample            # Environment variable template
├── analysis_options.yaml  # Dart analysis configuration
├── mise.toml              # mise tool configuration
├── pubspec.yaml           # Flutter dependencies
└── README.md
```

---

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `USER_NAME` | GitHub username | ✅ |
| `GITHUB_TOKEN` | GitHub Personal Access Token | ✅ |
| `GIST_ID` | GitHub Gist ID for data storage | ✅ |
| `USER_ID` | Application user identifier | ✅ |
| `PASSWORD` | User password (if required) | ❌ |
| `WALLET_ACCOUNT_ID` | Default wallet account ID | ❌ |
| `BANK_ACCOUNT_ID` | Default bank account ID | ❌ |
| `IS_DEVELOPMENT_MODE` | Enable development features | ❌ |

### Analysis Options

The project uses `flutter_lints` for code analysis. Configuration is in `analysis_options.yaml`.

### IDE Configuration

- **VS Code**: Configuration in `.vscode/`
- **IntelliJ/Android Studio**: Configuration in `.idea/`

---

## 🔧 Technologies

### Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| [Flutter](https://flutter.dev/) | 3.19.6 | UI Framework |
| [Dart](https://dart.dev/) | ≥3.3.0 | Programming Language |
| [Kotlin/Native](https://kotlinlang.org/docs/native-overview.html) | Latest | Native Library |
| [Java (Zulu)](https://www.azul.com/downloads/) | 21 | Kotlin/Native Build |

### Flutter Dependencies

| Package | Purpose |
|---------|---------|
| `motion_toast` | Toast notifications |
| `await_sleep` | Async delay operations |
| `audio_in_app` | Audio playback |
| `dropdown_search` | Searchable dropdowns |
| `envied` | Environment variable handling |
| `integer` | Extended integer support |

### Development Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_lints` | Code linting |
| `envied_generator` | Environment code generation |
| `build_runner` | Code generation |
| `analyzer` | Static analysis |

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone --recursive https://github.com/YOUR_USERNAME/Account_Ledger_Desktop_Flutter.git
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Development Workflow

1. Make your changes following the existing code style
2. Run the analyzer:
   ```bash
   flutter analyze
   ```
3. Format your code:
   ```bash
   dart format lib/
   ```
4. Test your changes locally on all target platforms if possible
5. Commit your changes with a descriptive message

### Pull Request Process

1. Update documentation if needed
2. Ensure the CI build passes
3. Create a Pull Request with a clear description
4. Wait for review and address any feedback

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Reporting Issues

When reporting issues, please include:
- Operating system and version
- Flutter version (`flutter --version`)
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) for the amazing framework
- [JetBrains](https://www.jetbrains.com/) for Kotlin/Native
- All contributors who have helped improve this project

---

<div align="center">

**Made with ❤️ by [Baneeishaque](https://github.com/Baneeishaque)**

⭐ Star this repository if you find it helpful!

</div>
