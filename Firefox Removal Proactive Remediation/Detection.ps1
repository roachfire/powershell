# Detection script for Mozilla Firefox

# Define the installation directory and executable names for Firefox
$firefoxInstallDirectory = "C:\Program Files\Mozilla Firefox"
$firefoxExecutables = @("firefox.exe")

# Check if Firefox is installed by verifying the existence of the installation directory
if (Test-Path $firefoxInstallDirectory) {
    Write-Host "Mozilla Firefox is installed."

    # Additional check for executable files
    $executableFound = $false
    foreach ($executable in $firefoxExecutables) {
        $executablePath = Join-Path $firefoxInstallDirectory $executable
        if (Test-Path $executablePath) {
            $executableFound = $true
            Write-Host "Found $executable at $executablePath"
        }
    }

    if (-not $executableFound) {
        Write-Host "Executable files not found. Firefox may not be fully installed."
    }
} else {
    Write-Host "Mozilla Firefox is not installed."
}

# Exit code for detection
# 1 means detection successful and the script will be run (Firefox is installed)
# 0 means detection unsuccessful and the script will not be run (Firefox is not installed)
if ($executableFound) {
    exit 1
} else {
    exit 0
}
