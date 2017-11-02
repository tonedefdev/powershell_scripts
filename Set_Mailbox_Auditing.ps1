Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

$Users = Get-Content "C:\users\aowens\desktop\mailboxauditing.txt"

foreach ($User in $Users) {

    Write-Host "Processing audit change for $User" -ForegroundColor Cyan
    Set-Mailbox -Identity $User -AuditEnabled $true

}