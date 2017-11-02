Import-Csv -Path "C:\users\aowens\desktop\server list\hospital domain IP-name Reference.csv" | foreach {

$Computer = $_.IPAddress
$FQDN = $_.Computer
    
    if (!(Test-Connection -Count 2 $Computer -ErrorAction SilentlyContinue)) {
        
        "`n"
        
        Write-Host "Connection to $FQDN could not be established" -ForegroundColor Red

        Continue

    } else {

        "`n"

        Write-Host "$FQDN " -NoNewline
        Write-Host "[" -NoNewline
        Write-Host "Connected" -NoNewline -ForegroundColor Green
        Write-Host "]" -NoNewline

        "`n"

        C:\PSTools\psexec.exe \\$Computer -u "hospital\servicedesk" -p 'Yo$h122!' -d cmd.exe /c "dnscmd $FQDN /zoneadd nvacare.com /secondary 10.253.69.2"
        C:\PSTools\psexec.exe \\$Computer -u "hospital\servicedesk" -p 'Yo$h122!' -d cmd.exe /c "dnscmd $FQDN /zoneadd nvashare.com /secondary 10.253.69.2"
        C:\PSTools\psexec.exe \\$Computer -u "hospital\servicedesk" -p 'Yo$h122!' -d cmd.exe /c "dnscmd $FQDN /zoneadd nvanet.com /secondary 10.253.69.2"
    }
}