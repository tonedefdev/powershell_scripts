$filePath = "C:\Users\$env:username\desktop"
$ou = "ou=,ou=,dc=,dc="
Get-ADComputer -SearchBase $ou -Filter {Enabled -eq $true} | Select-Object -ExpandProperty name > $filePath\computers.txt