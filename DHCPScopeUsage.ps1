Write-Output '<module>'
Write-Output '<name>DHCP Scope Monitor/name>'
Write-Output '<type>generic_data_string</type>'
Write-Output '<description>Monitors all DHCP scopes and provides usage telemetry</description>'
Write-Output '<data><![CDATA['
$Scopes = Get-DhcpServerv4ScopeStatistics
$Scopes | Select ScopeId,Free,InUse,PercentageInUse | Sort PercentageInUse -Descending
Write-Output ']]></data>'
Write-Output '</module>'