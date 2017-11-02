Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
. "C:\Users\$env:username\Desktop\Write_Log_Function.ps1"
$host.ui.rawui.WindowTitle = "Add Primary SMTP Address"
$logpath = "C:\Users\$env:username\Desktop\Primary SMTP Address.log"
$createlog = New-Item $logpath -Type File -ErrorAction SilentlyContinue

if ((Test-Path -Path $logpath -Type Leaf -ErrorAction SilentlyContinue) -eq $false)
	{
		$createlog
	}

$emailList = "C:\Users\$env:username\Desktop\emaillist.csv"
Import-CSV $emailList | Foreach {
$mailbox = Get-Mailbox -Identity $_.Alias
$mailid = $mailbox | Select-Object -ExpandProperty Alias
$emailAddress = $_.EmailAddress
try 
    {
        $mailbox | Set-Mailbox -PrimarySmtpAddress $emailAddress -EmailAddressPolicyEnabled $false ;
        Start-Sleep -Seconds 1
        $domain = "pet-er.net"
        if ($mailbox.PrimarySmtpAddress.Domain -eq $domain) {
		Write-Host $mailid":" "Successfully Added Primary SMTP Address" -BackgroundColor DarkBlue ;
        	Write-Log INFO -Path $logpath -Variable $mailid -Message "Successfully added primary SMTP address"
                                                            }
    }
catch [Microsoft.Exchange.Management.RecipientTasks.GetMailbox]
    {
        Write-Host $mailid":" "The username could not be found, please enter a valid username and try again." -Background Red ;
        Write-Log ERROR -Path $logpath -Variable $mailid -Message "The username could not be found"
    }
                                }
Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")