Import-Module ActiveDirectory
$filePath = "C:\Users\$env:username\desktop"
$datecutoff = (Get-Date).AddDays(-60)
Get-ADUser -Filter {(Enabled -eq $true)} -Properties LastLogonDate,Description | where {($_.Description -notlike "*Hospital Kiosk Accoun*") -and ($_.Description -notlike "*Thin-Client*") -and ($_.Description -notlike "*Thin Client*") -and ($_.Description -notlike "*Built-in*")} | Sort LastLogonDate | Format-List Name,LastLogonDate,Description | Out-File "$filePath\activeusers.csv"
