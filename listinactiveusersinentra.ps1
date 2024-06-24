# Set execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Get path to Documents folder
$documentsFolder = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)

# Set up log file path in Documents folder
$logFilePath = Join-Path -Path $documentsFolder -ChildPath "ScriptErrors.log"

# Set up CSV file path in Documents folder
$csvFilePath = Join-Path -Path $documentsFolder -ChildPath "InactiveUsers.csv"

# Function to log errors
function Log-Error {
    param(
        [string]$Message
    )
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: $Message"
}

try {

    Import-Module PowerShellGet

    # Install required modules
    Install-Module Microsoft.Graph -Scope CurrentUser -Force -ErrorAction Stop
    Install-Module Microsoft.Graph.Beta -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
    Install-Module Microsoft.Graph.Users -Scope CurrentUser -Force -ErrorAction Stop
    Install-Module -Name PackageManagement -Force -Scope AllUsers -ErrorAction Stop

    # Import required modules
    Import-Module Microsoft.Graph.Users -ErrorAction Stop
    Import-Module PackageManagement -ErrorAction Stop

    # Connect to Microsoft Graph
    Connect-MgGraph -Environment USGov -Scope AuditLog.Read.All,Directory.Read.All -ErrorAction Stop

    # Set inactive date threshold
    $inactiveDate = (Get-Date).AddDays(-30)

    # Retrieve users from Microsoft Graph
    $users = Get-MgUser -All:$true -Property Id, DisplayName, AccountEnabled, UserPrincipalName, UserType, SignInActivity | Where-Object { $_.AccountEnabled -eq $true }

    # Filter inactive users
    $inactiveUsers = $users | Where-Object {
        $_.SignInActivity.LastSignInDateTime -lt $inactiveDate
    } | Select-Object DisplayName, UserPrincipalName, UserType, @{Name="LastSignInDateTime"; Expression={$_.SignInActivity.LastSignInDateTime}}

    # Check if there are any inactive users
    if ($inactiveUsers.Count -eq 0) {
        Write-Host "No inactive users found."
    } else {
        # Export inactive users to CSV in Documents folder
        $inactiveUsers | Export-Csv -Path $csvFilePath -NoTypeInformation

        # Display inactive users to console (optional)
        $inactiveUsers
    }
}
catch {
    # Log the error to file
    $errorMessage = $_.Exception.Message
    Log-Error -Message $errorMessage

    # Display error message to console
    Write-Host "Error: $errorMessage"
}

# End of script
