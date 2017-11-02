$host.ui.rawui.WindowTitle = "Test SMTP Relay"
$from = "helpdesk@nvanet.com"
$recipients = @("Anthony Owens <aowens@nvanet.com>", "Thomas Corning <Thomas.Corning@nvanet.com")
$subject = "SMTP Relay Test"
$body = "This is a test message ensuring that SMTP relay is working"
$SMTPServer = "nvaexch.nva.local"

Send-MailMessage -From $from -To $recipients -Subject $subject -Body $body -SmtpServer $SMTPServer