Import-Module ActiveDirectory

$users = Get-Content -Path "C:\users\$env:USERNAME\desktop\8_26_migration.csv"
$server = "ES-DC1.labspace.com"

foreach ($user in $users)
{
    Write-Host "Removing $user home directory..."
    $userAccount = Get-ADUser -Filter {anr -eq $user} -Properties HomeDirectory,HomeDrive -Server $server
    $userAccount | Set-ADUser -HomeDrive $null -Server $server -Verbose
}