Import-Module ActiveDirectory
function sendMail ([string]$myMessage,[string]$myEmail){
Write-Host "Sending Email"
$finalMessage = "" + $myMessage + "`r`n`n"
$finalMessage = "" + $finalMessage + "On Windows computers that are connected
to the business network, "
$finalMessage = "" + $finalMessage + "press ctrl-alt-del and select 'Change a
password'.`r`n`n"
$finalMessage = "" + $finalMessage + "If you are not in the office, meaning you are a
VPN user, please, connect to VPN first"
$finalMessage = "" + $finalMessage + "'https://mail.hotelazaza.com/owa'. Click options in the upper right" 
$finalMessage = "" + $finalMessage + "and then click Change password from the panel in the options menu.`r`n`n"
$finalMessage = "" + $finalMessage + "If you have any questions please call the
helpdesk at 888-705-7827."
$smtpServer = "hzhou-v-exch.hotelzaza.com"
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "From email address (igmas_helpdes@hotelzaza.com)"
$msg.ReplyTo = "Reply to email address(donotreply@hotelzaza.com)"
$msg.To.Add("$myEmail")
$msg.subject = "Password Expiration Notification"
$msg.body = "$finalMessage"
$smtp.Send($msg)
}
$today = Get-Date
$passwordPolicy = Get-ADDefaultDomainPasswordPolicy
$strFilter = "(&(objectCategory=User)(useraccountcontrol=512))"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"

$colProplist = "name", "mail", "pwdlastset", "useraccountcontrol"
foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}
$colResults = $objSearcher.FindAll()
foreach ($objResult in $colResults){
$objItem = $objResult.Properties
$passwordLastSet = [datetime]::fromfiletime($objItem.pwdlastset[0])
$expireDate = $passwordLastSet + $PasswordPolicy.MaxPasswordAge
$daysLeft = $expireDate - $today
$message = ""
if ($daysLeft.Days -eq 10){
$message = "" + $ObjItem.name + ", Your password will expire in 10
days."
sendmail $message $ObjItem.mail
}
elseif ($daysLeft.Days -le 5 -and $daysLeft.Days -ge 2){
$message = "" + $ObjItem.name + ", Your password will expire in " +
$daysLeft.days + " days! Please change as soon as possible."
sendmail $message $ObjItem.mail
}
elseif ($daysLeft.Days -eq 1){
$message = "" + $ObjItem.name + ", Your password is expiring! Change
Now!"
sendMail $message $ObjItem.mail
}
}