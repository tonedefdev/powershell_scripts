Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
$ADVMList = "C:\users\$env:username\desktop\advmlist.csv"
$ObjectHT = @()
Import-CSV $ADVMList | Foreach {
    $Name = $_.SamAccountName
    $Access = Get-MailboxStatistics -Identity $Name -ErrorAction SilentlyContinue | Select-Object DisplayName,LastLogonTime,LastLoggedOnUserAccount

    if ($Access -eq $null) {
        $Access = ""
        $AccessAudit = New-Object System.Object
        $AccessAudit | Add-Member -Type NoteProperty -Name Name -Value $_.Name
        $AccessAudit | Add-Member -Type NoteProperty -Name MailboxLastAccessed -Value $Access
	    $AccessAudit | Add-Member -Type NoteProperty -Name LastLoggedOnUserAccount -Value ""
        $ObjectHT += $AccessAudit
    }
    else {
        $AccessAudit = New-Object System.Object
        $AccessAudit | Add-Member -Type NoteProperty -Name Name -Value $Access.DisplayName
        $AccessAudit | Add-Member -Type NoteProperty -Name MailboxLastAccessed -Value $Access.LastLogonTime
	    $AccessAudit | Add-Member -Type NoteProperty -Name LastLoggedOnUserAccount -Value $Access.LastLoggedOnUserAccount
        $ObjectHT += $AccessAudit
    }
}

$ObjectHT | Select-Object Name,MailboxLastAccessed,LastLoggedOnUserAccount | Sort-Object Name | Export-Csv -Path "C:\users\$env:username\desktop\advmmailboxaccess.csv"