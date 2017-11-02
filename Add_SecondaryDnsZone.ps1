$Computers = Get-Content "C:\users\aowens\desktop\dnsissues.txt"

foreach ($Computer in $Computers) {
C:\PSTools\psexec.exe \\$Computer -s -d cmd.exe /c "dnscmd $Computer /zoneadd nvacare.com /secondary 10.253.69.2"
C:\PSTools\psexec.exe \\$Computer -s -d cmd.exe /c "dnscmd $Computer /zoneadd nvashare.com /secondary 10.253.69.2"
C:\PSTools\psexec.exe \\$Computer -s -d cmd.exe /c "dnscmd $Computer /zoneadd nvanet.com /secondary 10.253.69.2"
}