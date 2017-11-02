$ScriptBlock = {
Param (
[parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
[string]$Computer
)

    if ((Test-Connection -Count 2 -ComputerName $Computer -Quiet -ErrorAction SilentlyContinue) -eq $true) {
    
        $Connected = "Connected"

        $KB = Get-WmiObject -ComputerName $Computer -Class win32_quickfixengineering | ? {$_.HotFixID -eq "KB4015549"}

        if ($KB.HotFixID -eq "KB4015549") {
        
            $HotFixInstalled = "Pass"
    
        } else {
    
            $HotFixInstalled = "Fail"
    
        }

        $AuditReport = New-Object System.Object
        $AuditReport | Add-Member -Type NoteProperty -Name Server -Value $Computer
        $AuditReport | Add-Member -Type NoteProperty -Name Connection -Value $Connected
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixInstalled -Value $HotFixInstalled
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixID -Value $KB.HotFixID
        $AuditReport | Add-Member -Type NoteProperty -Name InstalledOn -Value $KB.InstalledOn
        $AuditReport

    } else {

        $Connected = "Unable to connect"

        $AuditReport = New-Object System.Object
        $AuditReport | Add-Member -Type NoteProperty -Name Server -Value $Computer
        $AuditReport | Add-Member -Type NoteProperty -Name Connection -Value $Connected
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixInstalled -Value " "
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixID -Value " "
        $AuditReport | Add-Member -Type NoteProperty -Name InstalledOn -Value " "
        $AuditReport

    }
}

Import-Module ActiveDirectory
$Computers = Get-ADComputer -Filter {(Enabled -eq $True)} -Properties OperatingSystem,DNSHostName | where {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*") -or ($_.OperatingSystem -like "*Windows Server 2016*")} | Sort DNSHostName | Select-Object -ExpandProperty DNSHostName
$Throttle = 20
$initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Throttle, $initialSessionState, $host)
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

While ($Jobs.Result.IsCompleted -contains $false)
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
$HTMLBody = $HTMLBody + "<H2>MS April Security Rollup Audit</H2>"
$HTMLBody = $HTMLBody + "</body>"
 
$Results | ConvertTo-Html -Head $HTMLHead -body $HTMLBody | Out-File "C:\Temp\MS_Patch.htm"
$Results | Export-CSV -Path "C:\Temp\MS_Patch.csv" -Force

$RunspacePool.Close()
$RunspacePool.Dispose()