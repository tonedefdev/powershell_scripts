$filePath = "C:\Users\$env:username\desktop"
$ou = "ou=,ou=,dc=,dc="
Get-ADComputer -SearchBase $ou -Filter {Enabled -eq $true} | Select-Object -ExpandProperty name > $filePath\computers.txt

$file = Get-Content "$filepath\computers.txt"

ForEach($i in $file)  {
$path = "\\$i\C$\Program Files (x86)\Micros Systems, Inc\OperaIFCController\"
$FileExists = Test-Path $path
if($FileExists -eq $True) { 
Write-Host $i":" "Opera IFC exists on this machine."
}
else {
Write-Host $i":" "Opera IFC does not exist on this machine."
}
}
Pause
