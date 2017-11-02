Import-Module ActiveDirectory
$users = "C:\Users\$env:username\Desktop\users.txt"
$list = Get-Content $users

foreach ($i in $list) {
$enabled = Try {Get-ADUser -Identity $i -Properties Enabled,Name | Select-Object Enabled,Name -ExpandProperty Enabled} Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {Write-Host $i":" "Account is not found" -BackgroundColor Red}
    if ($enabled -eq $true) {
    Get-ADUser -Identity $i -Properties Name | Select-Object -ExpandProperty Name | Add-Content "C:\Users\$env:username\Desktop\Active.csv"
    }
}