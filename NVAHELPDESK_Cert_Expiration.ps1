$Body = [System.Collections.ArrayList]@()
$Threshold  = (Get-Date).AddDays(30)
Dir "Cert:\LocalMachine\My" | Select Issuer,Subject,NotAfter | foreach {
                                                                        
                                                                        $Issuer = $_.Issuer
                                                                        $Subject = $_.Subject
                                                                        $Expiration = $_.NotAfter
                                
                                                                        if ($SSL.NotAfter -le $Threshold) {
                                                                                                            Continue
                                                                        }

                                                                        elseif ($SSL.NotAfter -ge $Threshold) {
                                                                                                                $body += ("Subject: $Subject" + "`n" + "Issuer: $Issuer" + "`n" + "Server: $Server" + "`n" + "Will expire in 30 days!" + "`n") 
                                                                        }
}

$from = "helpdesk@nvanet.com"
$recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>")
$subject = "SSL Certificates Set to Expire"
$SMTPServer = "nvaexch.nva.local"

if ($Body -ne $null) {
    Send-MailMessage -From $from -To $recipients -Subject $subject -Body ($body | Out-String) -SmtpServer $SMTPServer -Priority High 
                        }