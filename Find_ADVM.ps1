Import-Module ActiveDirectory
$filepath = "C:\Users\$env:username\desktop\ADVMList.csv"
$ADVMs = Get-ADUser -Filter {(Enabled -eq $true)} -Properties Description,Mail | Where {($_.Description -like "*Associate DVM*") -or ($_.Description -like "*ADVM*")}
$ADVMs | Select-Object Name,Description,Mail | Sort-Object Name | Export-Csv $filepath 