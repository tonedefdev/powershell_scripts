$wc = Invoke-WebRequest -URI http://myip.dnsomatic.com/ 
$publicip = $wc.Content
$host.ui.rawui.WindowTitle = "Public IP Change Detector"
$currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
$keyinfoip = "207.178.233.193"
$attip = "209.36.38.227"
$from = "nvahelpdeskagoura@gmail.com"
$credentials = New-Object Management.Automation.PSCredential "nvahelpdeskagoura@gmail.com", ( "SmtpR3lay" | ConvertTo-SecureString -AsPlainText -Force) 
$recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>")
$subject = "Public IP Address Has Changed"
$date = Get-Date
$body = "The Public IP address has changed from AT&T to Key Info on $date. Current IP Address: $publicip" 
$recovered = "The AT&T IP address has been restored at $date. Current IP Address: $publicip"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
$logpath = "C:\Temp\Public IP Monitor.log"

do 
    {
        Start-Sleep -Seconds 60
            
            if ($publicip -eq $attip)
                {
                    if ((Test-Path -Path $logpath -PathType Leaf) -eq $true)
                        { 
                            Remove-Item -Path $logpath ;
                            Send-MailMessage -From $from -To $recipients -Subject $subject -Body $recovered -SmtpServer $SMTPServer -Port $SMTPPort -Credential $credentials -UseSsl -Priority High
                        }
                }

            if ((Test-Path -Path $logpath -PathType Leaf) -eq $true)
                {
                    Break
                }

            if ($publicip -ne $attip) 
                {   
                    $createlog = New-Item -Path $logpath -Type File -ErrorAction SilentlyContinue ;
                    Send-MailMessage -From $from -To $recipients -Subject $subject -Body $body -SmtpServer $SMTPServer -Port $SMTPPort -Credential $credentials -UseSsl -Priority High ;
                    Break
                }
    }
while ($publicip -eq $attip)

if ($publicip -ne "") {
	& "$currentPath\Get_PublicIP_Send_E-mail.ps1"
					  }
    