Import-Module ActiveDirectory
$filePath = "C:\Users\$env:username\desktop"
$ou = "CN=computers,dc=NVA,dc=local"
$datecutoff = (Get-Date).AddDays(-60)
Get-ADComputer -SearchBase $ou -Properties LastLogonDate -Filter {Enabled -eq $true -and LastLogonDate -lt $datecutoff} | Sort LastLogonDate | Format-Table Name,LastLogonDate | Out-File $filePath\computers.txt