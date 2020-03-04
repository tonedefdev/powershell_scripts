Write-Output '<module>'
Write-Output '<name>Umbrella External Resolver Verification</name>'
Write-Output '<type>generic_data_string</type>'
Write-Output '<description>Verifies that Umbrella can resolve external DNS names to IP addresses</description>'
Write-Output '<data><![CDATA['
$umbrella = "10.1.21.137"
$externalServer = "google.com"
nslookup $externalServer $umbrella 2>&1 | Out-File "C:\Temp\external.txt"
$query = Get-Content "C:\Temp\external.txt"
if ($query -match "Non-authoritative answer")
{
    Write-Output "Success"
} else {
    Write-Output "Critical error: Umbrella is unable to resolve DNS queries"
}
Write-Output ']]></data>'
Write-Output '</module>'