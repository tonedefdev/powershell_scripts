Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
. "C:\Users\$env:username\Desktop\Write_Log_Function.ps1"
$host.ui.rawui.WindowTitle = "Bulk Mailbox Creation"
$creationList = "C:\Users\$env:username\Desktop\Bulk Mailbox Creation.csv"
$logpath = "C:\Users\$env:username\Desktop\MailboxCreationLog.log"
$createlog = New-Item $logpath -Type File

if ((Test-Path -Path $logpath -Type Leaf) -eq $false)
	{
		$createlog
	}

Import-CSV $creationList | Foreach {
$emailAddress = $_.emailLogin
$password = $_.password
$first = $_.firstname
$last = $_.lastname
$display = $_.fullname
$alias = $_.alias
$database = $_.database
$ou = "Users"
"`n"
New-Mailbox -UserPrincipalName $emailAddress -Alias $alias -Database $database -Name $display -OrganizationalUnit $ou -Password (ConvertTo-SecureString $password -AsPlainText -Force) -FirstName $first -LastName $last -DisplayName $display -ResetPasswordOnNextLogon $false ;
Start-Sleep -Seconds 2
$mailid = Get-Mailbox -Identity $alias | Select-Object -ExpandProperty Alias

if ($mailid -eq $alias) {
	Write-Host "Account successfully created" -BackgroundColor DarkBlue ; 
        Write-Log INFO -Mailid $mailid -Message "Account successfully created"
                        }
elseif ($mailid -ne $alias) {
	Write-Host "Account was not successfully created" -BackgroundColor Red ;
        Write-Log ERROR -Mailid $mailid -Message "Account was not successfully created"
                            }
                                   }
Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")