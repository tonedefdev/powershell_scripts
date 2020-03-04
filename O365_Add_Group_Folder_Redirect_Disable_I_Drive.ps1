$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Choose the CSV file that contains users to be migrated"
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$csv = Get-FileName

$addToGroup = Import-Csv -Path $csv
$server = "ES-DC1.labspace.com"
$group = "Folder Redirect GPO Disable"

foreach ($user in $addToGroup)
{
    try
    {
        Write-Host "Adding $user to group..."
        $userAccount = Get-ADUser -Filter {anr -eq $user} -Server $server -Properties HomeDrive,HomeDirectory
        $userAccount | Add-ADPrincipalGroupMembership -MemberOf $group -Server $server -Verbose
        Write-Host "Removing $user I: drive..."
        $userAccount | Set-ADUser -HomeDrive $null -HomeDirectory $null -Server $server -Verbose
    }
    catch
    {
        throw $Error
    }
}