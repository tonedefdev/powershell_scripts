Import-Module ActiveDirectory

$Computers = Get-ADComputer -Filter {(Enabled -eq $True)} -Properties OperatingSystem,DNSHostName | where {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*") -or ($_.OperatingSystem -like "*Windows Server 2016*")} | Sort DNSHostName | Select-Object -ExpandProperty DNSHostName

$Computers -match '[0-9]\w{3}'

$Matches | Out-File "C:\users\$env:username\desktop\hosptialservers.txt"