Import-Module ActiveDirectory
$filepath = "C:\Users\$env:username\desktop\HMList.csv"
$HMs = Get-ADUser -Filter {(Enabled -eq $true)} -Properties Description,Mail | Where {($_.Description -like "*Hospital Manager*") -or ($_.Description -like "*HM*")}
$HMs | Select-Object Name,Description,Mail | Sort-Object Name | Export-Csv $filepath