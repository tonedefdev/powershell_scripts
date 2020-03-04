Write-Output '<module>'
Write-Output '<name>DFS Service Monitor</name>'
Write-Output '<type>generic_data_string</type>'
Write-Output '<description>Monitors services related to DFS</description>'
Write-Output '<data><![CDATA['
Get-Service -Name * | ? {$_.DisplayName -like "DFS*"}
Get-Service -Name * | ? {$_.DisplayName -eq "Server"}
Write-Output ']]></data>'
Write-Output '</module>'