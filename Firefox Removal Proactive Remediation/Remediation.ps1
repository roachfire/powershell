# Remediation script to uninstall Mozilla Firefox using the uninstall helper

# Define the path to the Firefox uninstall helper
$firefoxUninstallerPath = "C:\Program Files\Mozilla Firefox\uninstall\helper.exe"

# Check if the uninstaller executable exists
if (Test-Path $firefoxUninstallerPath) {
    # Uninstall Firefox using the uninstall helper
    Write-Host "Uninstalling Mozilla Firefox using the uninstall helper..."
    Start-Process -FilePath $firefoxUninstallerPath -ArgumentList "/S" -Wait

    # Check if uninstallation was successful
    $isUninstalled = -not (Test-Path $firefoxUninstallerPath)
    if ($isUninstalled) {
        Write-Host "Mozilla Firefox successfully uninstalled."
        # You may want to include additional cleanup steps if needed
    } else {
        Write-Host "Failed to uninstall Mozilla Firefox using the uninstall helper."
        # You may want to log or handle the failure appropriately
    }
} else {
    Write-Host "Mozilla Firefox uninstall helper not found at $firefoxUninstallerPath. Unable to uninstall."
}

# Exit code for remediation
# 0 means remediation successful (Firefox uninstalled or not installed)
# 1 means remediation unsuccessful (Failed to uninstall Firefox)
if ($isUninstalled -or -not (Test-Path $firefoxUninstallerPath)) {
    exit 0
} else {
    exit 1
}
