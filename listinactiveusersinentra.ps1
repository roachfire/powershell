Import-Module Microsoft.Graph.Users

Connect-MgGraph -Environment USGov -Scope AuditLog.Read.All,Directory.Read.All

$inactiveDate = (Get-Date).AddDays(-30)

$users = Get-MgUser -All:$true -Property Id, DisplayName, AccountEnabled, UserPrincipalName, UserType, SignInActivity | Where-Object { $_.AccountEnabled -eq $true }

$inactiveUsers = $users | Where-Object {
    $_.SignInActivity.LastSignInDateTime -lt $inactiveDate
} | Select-Object DisplayName, UserPrincipalName, UserType, @{Name="LastSignInDateTime"; Expression={$_.SignInActivity.LastSignInDateTime}}


if ($inactiveUsers.Count -eq 0) {
    Write-Host "No inactive users found."
} else {
# Export to CSV
$csvFilePath = Join-Path -Path $PSScriptRoot -ChildPath "InactiveUsers.csv"
$inactiveUsers | Export-Csv -Path $csvFilePath -NoTypeInformation

# Display output to console (optional)
$inactiveUsers
}
