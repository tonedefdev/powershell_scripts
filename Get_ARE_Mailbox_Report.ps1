Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Import-Module ActiveDirectory

$Mailboxes = Get-Mailbox -IgnoreDefaultScope | ? {$_.PrimarySmtpAddress -notlike "*buildingsupport.net"}

$Array = @()

foreach ($Mailbox in $Mailboxes) {
    $Stats = Get-MailboxStatistics -Identity $Mailbox.Alias -ErrorAction SilentlyContinue
    $ADInformation = Get-ADUser -Identity $Mailbox.DistinguishedName -Properties Department -ErrorAction SilentlyContinue

    $Hash = @{
        User = $Mailbox.DisplayName
        Email = $Mailbox.PrimarySmtpAddress
        Department = $ADInformation.Department
        MailboxSize = $Stats.TotalItemSize.Value.ToMB()
        Database = $Stats.Database
    }
    
    $Object = New-Object -Type PSObject -Property $Hash
    $Array += $Object

}

$Array | Select User,Email,Department,MailboxSize,Database | Sort Department | Export-CSV -Path "C:\users\admin.aowens\Desktop\ARE Migration.csv" -NoTypeInformation