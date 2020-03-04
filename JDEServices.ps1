Write-Output '<module>'
Write-Output '<name>JDE Service Monitor</name>'
Write-Output '<type>generic_data_string</type>'
Write-Output '<description>Monitors JDE service status</description>'
Write-Output '<data><![CDATA['
Get-Service -Name * | ? {$_.DisplayName -eq "JDE E920 B9 Network"}
Write-Output ']]></data>'
Write-Output '</module>'