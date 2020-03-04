Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

$Mailboxes = Get-Mailbox -Identity *

$Array = @()

foreach ($Mailbox in $Mailboxes)
{
    $Audit = Get-MailboxStatistics -Identity $Mailbox.Name -ErrorAction SilentlyContinue | Select-Object DisplayName,Database,{$_.TotalItemSize.Value.TOMB()}
    $Params = @{
        DisplayName = $Audit.DisplayName
        "TotalItemSize(MB)" = $Audit.'$_.TotalItemSize.Value.TOMB()'
        Database = $Audit.Database
    }
    $Object = New-Object -TypeName PSObject -Property $Params
    $Array += $Object
}

$Array | Export-Csv "C:\Users\admin.aowens\Desktop\MailboxAudit.csv" -NoTypeInformation