$ScriptBlock = {
Param (
[parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
[string]$Computer
)

$ComputerManagementNamespace = 
    (Get-WmiObject -ComputerName $Computer -Namespace "root\microsoft\sqlserver" -Class "__NAMESPACE" |
        Where-Object {$_.Name -like "ComputerManagement*"} |
        Select-Object Name |
        Sort-Object Name -Descending |
        Select-Object -First 1).Name

if ($ComputerManagementNamespace -eq $null) {
    Write-Error "ComputerManagement namespace not found"
}
else {
    $ComputerManagementNamespace = "root\microsoft\sqlserver\" + $ComputerManagementNamespace
} 
    $SQLGrab = Get-WmiObject -ComputerName $Computer -Namespace $ComputerManagementNamespace -Class "SqlServiceAdvancedProperty" | where {$_.PropertyName -eq "VERSION"}
    $SQLVersion = $SQLGrab.PropertyStrValue -replace "[^0-9]\d{1,5}"
        Switch ($SQLVersion) {
            9 {$SQLVersion = "SQL Server 2005"}
            10 {$SQLVersion = "SQL Server 2008"}
            11 {$SQLVersion = "SQL Server 2012"}
            12 {$SQLVersion = "SQL Server 2014"}
            13 {$SQLVersion = "SQL Server 2016"}
            Default {$SQLVersion = "No instance of SQL installed on this server."}
    }

    $SKU = Get-WmiObject -ComputerName $Computer -Namespace $ComputerManagementNamespace -Class "SqlServiceAdvancedProperty" | where {$_.PropertyName -eq "SKUNAME"}

    $ObjectHT = @{
        SQLVersionInstalled = ($SQLVersion + " " + ($SKU.PropertyStrValue | Get-Unique))
    }

    $SQLVersion = New-Object PSObject -Property $ObjectHT

    Import-Module DHCPServer

    $ScopeID = Get-DhcpServerv4Scope -ComputerName $Computer
    $Hosts = Get-DhcpServerv4Lease -ComputerName $Computer -ScopeId $ScopeID.ScopeID
    $Total = $Hosts.Hostname -match  "^(?=[1-9])\d{3}" | Measure-Object 
        $ObjectHT1 = @{
            HostCount = $Total.Count
        }
  

    $HostCount = New-Object PSObject -Property $ObjectHT1

    $OSVersion = (Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem).Caption

    $CPUS = Get-WmiObject -ComputerName $Computer -class Win32_processor | Select -ExpandProperty NumberOfLogicalProcessors -First 1

    $OfficeVersion = Get-WmiObject -ComputerName $Computer -Class Win32_Product | where { ($_.name -like '*office standard*') -or ($_.name -like '*office professional*') }

    $AuditReport = New-Object System.Object
    $AuditReport | Add-Member -Type NoteProperty -Name Server -Value $Computer
    $AuditReport | Add-Member -Type NoteProperty -Name OperatingSystem -Value $OSVersion
    $AuditReport | Add-Member -Type NoteProperty -Name DeviceCALs -Value $HostCount.HostCount
    $AuditReport | Add-Member -Type NoteProperty -Name CPUCores -Value $CPUS
    $AuditReport | Add-Member -Type NoteProperty -Name SQLVersion -Value $SQLVersion.SQLVersionInstalled
    $AuditReport | Add-Member -Type NoteProperty -Name OfficeVersion -Value $OfficeVersion.Name
    $AuditReport
    
}

$Computers = Get-Content -Path "C:\users\aowens\desktop\computers.txt"
$Throttle = 15
$initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Throttle, $initialSessionState,$host)
$RunspacePool.Open()
$Jobs = @()

Foreach ($Computer in $Computers) {   
   $Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($Computer)
   $Job.RunspacePool = $RunspacePool
   $Jobs += New-Object PSObject -Property @{
      Pipe = $Job
      Result = $Job.BeginInvoke()
   }
}
 
Write-Host "Waiting.." -NoNewline
Do {
   Write-Host "." -NoNewline
   Start-Sleep -Seconds 1
} 
While ( $Jobs.Result.IsCompleted -contains $false)
Write-Host "All jobs completed!"
 
$Results = @()
ForEach ($Job in $Jobs)
{   $Results += $Job.Pipe.EndInvoke($Job.Result)
}

$HTMLHead = "<style>"
$HTMLHead = $HTMLHead + "BODY{background-color:white;}"
$HTMLHead = $HTMLHead + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$HTMLHead = $HTMLHead + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "</style>"

$NVALogo = "http://i.imgur.com/idZOZ2g.jpg"

$HTMLBody = "<body>"
$HTMLBody = $HTMLBody + "<img src=$NVALogo>"
$HTMLBody = $HTMLBody + "<H2>MS Licensing Audit</H2>"
$HTMLBody = $HTMLBody + "</body>"
 
$Results | ConvertTo-Html -Head $HTMLHead -body $HTMLBody | Out-File "C:\Temp\MS_Licensing.htm"
$Results | Export-CSV -Path "C:\Temp\MS_Licensing.csv" -Force

$RunspacePool.Close()
$RunspacePool.Dispose()