Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

$Mailboxes = Get-Mailbox -IgnoreDefaultScope | ? {$_.PrimarySmtpAddress -like "*buildingsupport.net"}

$Array = @()

foreach ($Mailbox in $Mailboxes) {
    $Stats = Get-MailboxStatistics -Identity $Mailbox.Alias -ErrorAction SilentlyContinue

    $Hash = @{
        User = $Mailbox.DisplayName
        Email = $Mailbox.PrimarySmtpAddress
        MailboxSize = $Stats.TotalItemSize
        Database = $Stats.Database
    }
    
    $Object = New-Object -Type PSObject -Property $Hash
    $Array += $Object

}

$Array | Select User,Email,MailboxSize,Database | Sort User | Export-CSV -Path "C:\users\admin.aowens\Desktop\Building Support Migration.csv"