Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
$host.ui.rawui.WindowTitle = "Exchange Database Server Check"
$databases = Get-MailboxDatabase -Identity * | Select-Object -ExpandProperty Name
$from = "helpdesk@nvanet.com"
$recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>")
$subject = "Exchange Database Server Changed"
$date = Get-Date
$SMTPServer = "nvaexch.nva.local"
$body = [System.Collections.ArrayList]@()

Foreach ($edb in $databases) {
    $server = Get-MailboxDatabase -Identity $edb
        if ($server.server.name -eq "NVAEXCH2") {
        	$body += ("The Exchange Database $edb has moved from NVAEXCH3 to NVAEXCH2 at" + $server.whenchanged + "`n")
                                                }
                             }

if ($body -ne $null) {
    Send-MailMessage -From $from -To $recipients -Subject $subject -Body ($body | Out-String) -SmtpServer $SMTPServer -Priority High 
                     }