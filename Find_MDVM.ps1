Import-Module ActiveDirectory
$filepath = "C:\Users\$env:username\desktop\MDVMList.csv"
$MDVMs = Get-ADUser -Filter {(Enabled -eq $true)} -Properties Description,Mail | Where {($_.Description -like "*Managing DVM*") -or ($_.Description -like "*MDVM*")}
$MDVMs | Select-Object Name,Description,Mail | Sort-Object Name | Export-Csv $filepath 