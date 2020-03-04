Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$recvConn = Get-ReceiveConnector -Identity "ES-16EXCH01\Anonymous Relay"
$servers = @("ES-16EXCH02","TX-16EXCH01","TX-16EXCH02")

foreach ($server in $servers)
{
    $toBeChanged = Get-ReceiveConnector -Identity "$server\Anonymous Relay"
    $comparison = Compare-Object -ReferenceObject $recvConn.RemoteIPRanges.Expression -DifferenceObject $toBeChanged.RemoteIPRanges.Expression
    
    if ($comparison -ne $null)
    {
        foreach ($ip in $comparison.InputObject)
        {
            $toBeChanged.RemoteIPRanges += $ip
        }

        Set-ReceiveConnector -Identity "$server\Anonymous Relay" -RemoteIPRanges $toBeChanged.RemoteIPRanges -Verbose

        $toBeChangedCheck = Get-ReceiveConnector -Identity "$server\Anonymous Relay"
        $comparison = Compare-Object -ReferenceObject $recvConn.RemoteIPRanges.Expression -DifferenceObject $toBeChangedCheck.RemoteIPRanges.Expression

        if ($comparison -eq $null)
        {
            Write-Host "Successfully added new IP addresses to $server" -ForegroundColor Cyan
        }
    } else {
        Write-Host "Anonymous relay IP addresses already synced for $server" -ForegroundColor Yellow
    }
}