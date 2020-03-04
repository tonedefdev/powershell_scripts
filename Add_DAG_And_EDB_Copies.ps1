Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.SnapIn
Add-DatabaseAvailabilityGroupServer -MailboxServer $env:COMPUTERNAME -Identity "DAG16"
Add-MailboxDatabaseCopy -MailboxServer $env:COMPUTERNAME -Identity "DB01_16"
Add-MailboxDatabaseCopy -MailboxServer $env:COMPUTERNAME -Identity "DB02_16"
Add-MailboxDatabaseCopy -MailboxServer $env:COMPUTERNAME -Identity "DB03_16"
Add-MailboxDatabaseCopy -MailboxServer $env:COMPUTERNAME -Identity "DB04_16"
Add-MailboxDatabaseCopy -MailboxServer $env:COMPUTERNAME -Identity "DB05_16"