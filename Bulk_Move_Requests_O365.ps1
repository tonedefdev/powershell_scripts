$userCredential = Get-Credential "automation@are.com"
$exchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell" -Credential $userCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $exchangeOnlineSession -AllowClobber -DisableNameChecking) -Global

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

Import-Csv -Path $csv | foreach {
    $user = $_.Email
    New-MoveRequest -Identity $user -Remote -RemoteHostName "mail.are.com" -TargetDeliveryDomain "arereit.mail.onmicrosoft.com" -AcceptLargeDataLoss -BadItemLimit 500 -LargeItemLimit 500
}

$exchangeOnlineSession | Remove-PSSession