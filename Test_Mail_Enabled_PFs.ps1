$mailPublicFolders = Import-Csv -Path "C:\users\admin.aowens\desktop\mailpublicfolders.csv"
$from = "DoNotReply@are.com"
$subject = "Testing mail enabled public folders post migration"
$body = "This e-mail is a test from ARE Tech to ensure that mail enabled public folders are still receiving e-mail post migration."
$smtpServer = "relay.are.com"

foreach ($folder in $mailPublicFolders)
{
    Send-MailMessage -To $folder.Address -From $from -Subject $subject -Body $body -SmtpServer $smtpServer -DeliveryNotificationOption OnSuccess
}