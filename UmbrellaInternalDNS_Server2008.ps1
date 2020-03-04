Write-Output '<module>'
Write-Output '<name>Umbrella Internal Resolver Verification</name>'
Write-Output '<type>generic_data_string</type>'
Write-Output '<description>Verifies that Umbrella can resolve internal DNS names to IP addresses</description>'
Write-Output '<data><![CDATA['
$umbrella = "10.1.21.137"
$internalServer = "es-dc1"
nslookup $internalServer $umbrella 2>&1 | Out-File "C:\Temp\internal.txt"
$query = Get-Content "C:\Temp\internal.txt"
if ($query -match "Non-authoritative answer")
{
    Write-Output "Success"
} else {
    Write-Output "Critical error: Umbrella is unable to resolve DNS queries"
}
Write-Output ']]></data>'
Write-Output '</module>'