Import-Module ActiveDirectory

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Choose the CSV file"
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$csv = Get-FileName

$badges = Import-Csv -Path $csv

foreach ($badge in $badges)
{
    $name = $badge.Name
    $user = Get-ADUser -Filter {anr -eq $name}
    if ($user)
    {
        Write-Host "Adding '$($badge.Badge)' to extensionattribute9 for '$($badge.Name)'" -ForegroundColor Cyan
        $user | Set-ADUser -Replace @{extensionattribute9=$badge.Badge} -Server "ES-DC1" -Verbose
    } else {
        throw "The user $($badge.Name) could not be found in Active Directory"
    }
}