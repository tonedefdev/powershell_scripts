$ADService = Get-Service -DisplayName "ManageEngine ADSelfService Plus"
$WWW = Get-Service -DisplayName "World Wide Web Publishing Service"

$Count = @()

if ($Count.Length -le 3) {

    if ($ADService.Status -eq "Stopped") {
        Start-Service -DisplayName "ManageEngine ADSelfService Plus" -Verbose
        $Count += 1
        Return
        }

    if ($WWW.Status -eq "Stopped") {
        Start-Service -DisplayName "World Wide Web Publishing Service" -Verbose
        $Count += 1
        Return
        }

} else {

    $from = "helpdesk@nvanet.com"
    $recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>", "Patrick Hong <phong@nvanet.com>")
    $subject = "NVA Password Portal Services Not Started"
    $SMTPServer = "nvaexch.nva.local"
    $body = "Services for https://password.nvanet.com are not starting properly, so the website is currently unavailable. Please, check the server's connectivity, and be sure that the ManageEngine ADSelfService Plus + WWW Publishing Service are currently started to ensure proper connectivity to the server!"
    if ($body -ne $null) {
        Send-MailMessage -From $from -To $recipients -Subject $subject -Body $body -SmtpServer $SMTPServer -Priority High
        }
}




    