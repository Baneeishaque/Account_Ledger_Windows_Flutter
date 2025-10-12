# This script implements a workaround to install Flutter using mise on Windows,
# where the default vfox backend is buggy.

# Exit on any error
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# 1. Read the flutter version dynamically from the root mise.toml file
Write-Host "Reading flutter version from mise.toml..."
$miseFile = "./mise.toml"
$flutterLine = Get-Content $miseFile | Select-String -Pattern 'flutter = "(.*)"'
if (-not $flutterLine) {
    Write-Error "Could not find flutter version in $miseFile"
    exit 1
}
$flutterVersion = $flutterLine.Matches[0].Groups[1].Value
$flutterToolVersion = "flutter@$flutterVersion"
Write-Host "Found tool version: $flutterToolVersion"


# 2. The "fail-then-retry" workaround
Write-Host "Attempting to install $flutterToolVersion..."

# First attempt. We use -ErrorAction SilentlyContinue and check the exit code manually.
mise use $flutterToolVersion -ErrorAction SilentlyContinue
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Host "Initial mise command failed as expected. Disabling vfox and retrying."
    
    # Disable the vfox backend
    mise settings set vfox false
    
    # Retry the command. If this fails, the script will exit due to $ErrorActionPreference = "Stop"
    mise use $flutterToolVersion
} else {
    Write-Host "Initial mise command succeeded. No retry needed."
}

# 3. Final verification to ensure flutter is on the PATH
Write-Host "Verifying flutter installation..."
flutter --version

Write-Host "SUCCESS: Flutter installation complete."
