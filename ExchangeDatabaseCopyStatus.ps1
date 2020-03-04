Write-Output '<module>'
Write-Output '<name>Exchange Database Copy Status</name>'
Write-Output '<type>generic_data_string</type>'
Write-Output '<description>Monitors Exchange database copy status</description>'
Write-Output '<data><![CDATA['
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Get-MailboxDatabaseCopyStatus *
Write-Output ']]></data>'
Write-Output '</module>'