Import-Module ActiveDirectory
$filepath = "C:\Users\$env:username\desktop\ResortManagers.csv"
$OU = "OU=.PetSuites,DC=NVA,DC=local"
$MDVMs = Get-ADUser -SearchBase $OU -Filter {(Enabled -eq $true)} -Properties Description,Mail | Where {($_.Description -like "*Manager*")}
$MDVMs | Select-Object Name,Description,Mail | Sort-Object Name | Export-Csv $filepath 