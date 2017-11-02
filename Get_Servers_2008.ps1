Import-Module ActiveDirectory
$filePath = "C:\Users\$env:username\Desktop"
$OU = "ou=,ou=,dc=,dc="
Get-ADComputer -SearchBase $OU -Filter {(Enabled -eq $True)} -Properties OperatingSystem,Name | where {($_.OperatingSystem -like "*Windows Server 2008*")} | Sort Name | Select-Object -ExpandProperty Name > "$filePath\nvaservers.txt"