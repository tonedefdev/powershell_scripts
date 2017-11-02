Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
$filepath = "C:\Users\$env:username\desktop\ADVMList.csv"
$ADVMs = Get-ADUser -Filter * -Properties Description,Mail,SamAccountName,Enabled,Created,LastLogonDate,LogonCount,PasswordExpired,PasswordNeverExpires,PasswordLastSet | Where {($_.Description -like "*Associate DVM*") -or ($_.Description -like "*ADVM*")}
$ADVMs | Select-Object Name,Description,Mail,SamAccountName,Enabled,Created,LastLogonDate,LogonCount,PasswordExpired,PasswordNeverExpires,PasswordLastSet | Sort-Object Name | Export-Csv $filepath