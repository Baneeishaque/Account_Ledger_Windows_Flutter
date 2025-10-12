# This script uses the vfox CLI to install the correct version of Flutter.

# Exit on any error
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# 1. Activate vfox for the current PowerShell session
Write-Host "Activating vfox for PowerShell..."
Invoke-Expression "$(vfox activate pwsh)"

# 2. Read the flutter version dynamically from the root mise.toml file
Write-Host "Reading flutter version from mise.toml..."
$miseFile = "./mise.toml"
$flutterLine = Get-Content $miseFile | Select-String -Pattern 'flutter = "(.*)"'
if (-not $flutterLine) {
    Write-Error "Could not find flutter version in $miseFile"
    exit 1
}
$flutterVersion = $flutterLine.Matches[0].Groups[1].Value
Write-Host "Found flutter version: $flutterVersion"

# 2. Use vfox to add and install Flutter
Write-Host "Adding and installing Flutter with vfox..."
vfox add flutter
vfox use "flutter@$flutterVersion"

# 3. Verify the installation
Write-Host "Verifying flutter installation..."
flutter --version

Write-Host "SUCCESS: Flutter installation via vfox complete."
