function Get-DHCPCount ($Computer) {
    $ScopeID = Get-DhcpServerv4Scope -ComputerName $Computer
    $Hosts = Get-DhcpServerv4Lease -ComputerName $Computer -ScopeId $ScopeID.ScopeID
    $Total = $Hosts.Hostname -match  "^(?=[1-9])\d{3}" | Measure-Object 
        $ObjectHT = @{
            HostCount = $Total.Count
        }
    $Object = New-Object PSObject -Property $ObjectHT
    $Object
}
