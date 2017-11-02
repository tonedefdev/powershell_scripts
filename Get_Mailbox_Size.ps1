Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
$host.ui.rawui.WindowTitle = "Get Mailbox Size"
$list = "C:\users\$evn:username\desktop\NVA Leadership Team.csv"
Import-Csv $list | Foreach {
$name = $_.Name
Get-MailboxStatistics -Identity $name | Format-List DisplayName,TotalItemSize | Out-File "C:\Users\$env:username\Desktop\mailboxsize.csv"
}
Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")