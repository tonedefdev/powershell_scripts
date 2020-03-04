Write-Output '<module>'
Write-Output '<name>DHCP Scope Monitor</name>'
Write-Output '<type>generic_data_string</type>'
Write-Output '<description>Monitors all DHCP scopes and provides usage telemetry</description>'
Write-Output '<data><![CDATA['
$Service = Get-Service -Name * | ? {$_.DisplayName -eq "DHCP Server"}
$Service.Status
Write-Output ']]></data>'
Write-Output '</module>'