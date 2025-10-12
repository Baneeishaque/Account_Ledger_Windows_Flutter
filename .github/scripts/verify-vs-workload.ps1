# This script verifies that the required Visual Studio C++ workload is installed.
# It's designed to be run from a GitHub Actions workflow.

# Strict mode helps catch common scripting errors.
Set-StrictMode -Version Latest

$vswherePath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

# 1. First, verify that vswhere.exe itself exists.
if (-not (Test-Path $vswherePath)) {
    Write-Error "FAIL: vswhere.exe not found at '$vswherePath'. Visual Studio installation could not be verified."
    exit 1
}

# 2. If it exists, use it to find the required workload.
$workload = "Microsoft.VisualStudio.Workload.NativeDesktop"
$vsPath = & $vswherePath -products * -requires $workload -property installationPath -prerelease

if (-not $vsPath) {
    Write-Error "FAIL: Visual Studio with the '$workload' (Desktop development with C++) workload was not found."
    exit 1
}

# 3. If all checks pass, print a success message.
Write-Host "SUCCESS: Found Visual Studio with C++ Desktop workload at: $vsPath"
exit 0
