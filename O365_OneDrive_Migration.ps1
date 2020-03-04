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

$migrationList = Import-Module -Path $csv

$migrationUsers = @()
foreach ($user in $migrationList)
{
    $account = Get-ADUser -Filter {anr -eq $user} -Properties HomeDirectory
    $params = [ordered]@{
        Source = $account.HomeDirectory
        SourceDocLib = ""
        SourceSubFolder = ""
        TargetWeb = "https://arereit-my.sharepoint.com/personal/$($account.SamAccountName)_are_com"
        TargetDocLib = "Documents"
        TargetSubFolder = ""
    }

    $object = New-Object -TypeName PSObject -Property $params
    $migrationUsers += $object
}

$migrationUsers | Export-Csv -Path "C:\users\$env:USERNAME\desktop\8_26_OneDrive_Migration.csv" -NoTypeInformation