function Remove-ExchangeMaintenance {
param(
    [string]$Computer,
    [string]$TargetServer
)
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
    Set-ServerComponentState $computer -Component ServerWideOffline -State Active -Requester Maintenance
    Resume-ClusterNode $computer
    Set-MailboxServer $computer -DatabaseCopyActivationDisabledAndMoveNow $false
    Set-ServerComponentState $computer -Component HubTransport -State Active -Requester Maintenance
    Restart-Service MSExchangeTransport
    Restart-Service MSExchangeFrontEndTransport
}