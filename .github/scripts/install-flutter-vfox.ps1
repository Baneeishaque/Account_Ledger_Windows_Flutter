# This script uses the vfox CLI to install the correct version of Flutter.

# Exit on any error
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# 1. Get flutter version from environment variable (set in workflow) or fallback to mise.toml
if ($env:FLUTTER_VERSION) {
    $flutterVersion = $env:FLUTTER_VERSION
    Write-Host "Using Flutter version from environment: $flutterVersion"
} else {
    Write-Host "Reading flutter version from mise.toml..."
    $miseFile = "./mise.toml"
    $flutterLine = Get-Content $miseFile | Select-String -Pattern 'flutter = "(.*)"'
    if (-not $flutterLine) {
        Write-Error "Could not find flutter version in $miseFile or environment variable"
        exit 1
    }
    $flutterVersion = $flutterLine.Matches[0].Groups[1].Value
    Write-Host "Found flutter version: $flutterVersion"
}

# 2. Use vfox to add and install Flutter
Write-Host "Adding and installing Flutter with vfox..."
vfox add flutter

Write-Host "Installing Flutter $flutterVersion with vfox..."
vfox install "flutter@$flutterVersion"

Write-Host "Setting Flutter $flutterVersion as the active version..."
vfox use -g "flutter@$flutterVersion"

# Activate vfox to ensure the environment is refreshed with the newly used Flutter version
Write-Host "Re-activating vfox for PowerShell to refresh environment..."
Invoke-Expression "$(vfox activate pwsh)"

# 3. Verify the installation
Write-Host "Verifying flutter installation..."
flutter --version

Write-Host "SUCCESS: Flutter installation via vfox complete."
