function Set-ExchangeMaintenance {
param(
    [string]$Computer,
    [string]$TargetServer
)
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
    Set-ServerComponentState $computer -Component HubTransport -State Draining -Requester Maintenance
    Restart-Service MSExchangeTransport
    Restart-Service MSExchangeFrontEndTransport
    Redirect-Message -Server $computer -Target $targetServer
    Suspend-ClusterNode $computer
    Set-MailboxServer $computer -DatabaseCopyActivationDisabledAndMoveNow $true

    $blocked = Get-MailboxServer $computer | Select DatabaseCopyAutoActivationPolicy
    if ($blocked.DatabaseCopyAutoActivationPolicy -ne "Blocked")
    {
        Set-ServerComponentState $computer -Component ServerWideOffline -State Inactive -Requester Maintenance
    }
}