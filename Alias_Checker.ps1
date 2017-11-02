Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
. "C:\Users\$env:username\Desktop\Write_Log_Function.ps1"
$host.ui.rawui.WindowTitle = "Alias Checker"
$creationList = "C:\Users\$env:username\Desktop\PetSuitesAlias.csv"
$logpath = "C:\Users\$env:username\Desktop\Verification.log"
$createlog = New-Item $logpath -Type File

if ((Test-Path -Path $logpath -Type Leaf) -eq $false)
	{
		$createlog
	}

Import-CSV $creationList | Foreach {
$alias = $_.alias   
$mailid = Get-Mailbox -Identity $alias | Select-Object -ExpandProperty Alias

if ($mailid -eq $alias) {
	Write-Host $alias ":" "An account with this alias already exists" -BackgroundColor Red ; 
        Write-Log ERROR -Alias $alias -Message "An account with this alias already exists"
                        }
elseif ($mailid -ne $alias) {
	Write-Host $alias ":" "No account exists by this alias" -BackgroundColor DarkBlue ;
        Write-Log INFO -Alias $alias -Message "No account exists by this alias"
                            }
                                   }
Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")