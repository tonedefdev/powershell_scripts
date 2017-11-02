$host.ui.rawui.WindowTitle = "Auto Test E-mail"
$from = "nvahelpdeskagoura@gmail.com"
$credentials = New-Object Management.Automation.PSCredential "nvahelpdeskagoura@gmail.com", ( "SmtpR3lay" | ConvertTo-SecureString -AsPlainText -Force) 
$subject = "E-mail Migration Test"
$body = "This is a test message ensuring that your e-mail gets delivered after the migration!"
$SMTPServer = "smtp.gmail.com"
$emaillist = "C:\users\$env:username\desktop\emaillist.csv"

Import-CSV $emaillist | Foreach {
$email = $_.EmailAddress
    Send-MailMessage -From $from -To $email -Subject $subject -Body $body -SmtpServer $SMTPServer -Port 587 -Credential $credentials -UseSsl -Priority High ;
    Write-Host "Sent e-mail to $email" -BackgroundColor DarkBlue
}

Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")