Import-Module ActiveDirectory
$filepath = "C:\Users\$env:username\desktop\NeverLoggedOn.csv"
$HMs = Get-ADUser -Filter * -Properties Description,LastLogonDate | Where {($_.LastLogonDate -eq $null)}
$HMs | Select-Object Name,Description,Mail,LastLogonDate | Sort-Object Name | Export-Csv $filepath