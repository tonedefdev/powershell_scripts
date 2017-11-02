. "C:\PSScripts\Write_Log_Function.ps1"
$Kaseya = "Kaseya DB"
$KaseyaDB = (Get-Item -Path "\\nvakes\D$\Kaseya_SQLDB\ksubscribers_dat.mdf").Length/1GB
$from = "helpdesk@nvanet.com"
$recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>")
$subject = "Kaseya Database Size Reaching Threshold"
$date = Get-Date
$SMTPServer = "nvaexch.nva.local"
$body = [System.Collections.ArrayList]@()

if ($KaseyaDB -ge 8) {
    Write-Host "DB is too big!" -ForegroundColor Red
    Write-Log -Path "C:\Temp\testlog.log" -Level INFO -Variable $Kaseya -Message ("size is $KaseyaDB" + " GB")
    $body += ("$Kaseya size is $KaseyaDB" + " GB")

    }
else
    {
    Write-Host "DB is just right!" -ForegroundColor Green
    Write-Log -Path "C:\Temp\testlog.log" -Level INFO -Variable $Kaseya -Message ("size is $KaseyaDB" + " GB")
}

if ($body -ne $null) {
    Send-MailMessage -From $from -To $recipients -Subject $subject -Body ($body | Out-String) -SmtpServer $SMTPServer -Priority High 
                     }