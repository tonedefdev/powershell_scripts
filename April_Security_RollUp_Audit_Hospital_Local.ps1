$ScriptBlock = {
Param (
[parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
[string]$Computer
)

    $Credential = New-Object Management.Automation.PSCredential "hospital\servicedesk", ('Yo$h122!' | ConvertTo-SecureString -AsPlainText -Force)

    if ((Test-Connection -Count 2 -ComputerName $Computer -Quiet -ErrorAction SilentlyContinue) -eq $true) {
    
        $Connected = "Connected"

        $Check = @()
        
        $KB = Get-WmiObject -ComputerName $Computer -Class win32_quickfixengineering -Credential $Credential

        if ($KB.HotFixID -eq "KB4015549") {
            $HotFixInstalled = "Pass"
            $HotFix = "KB4015549"
            $InstalledOn = $KB | ? {$_.HotFixID -eq "KB4015549"}
            $Check += 1
        }

        if ($KB.HotFixID -eq "KB4019264") {
            $HotFixInstalled = "Pass"
            $HotFix = "KB4019264"
            $InstalledOn = $KB | ? {$_.HotFixID -eq "KB4019264"}
            $Check += 1
        }   
        
        if ($KB.HotFixID -eq "KB4019215") {
            $HotFixInstalled = "Pass"
            $HotFix = "KB4019215"
            $InstalledOn = $KB | ? {$_.HotFixID -eq "KB4019215"}
            $Check += 1
        }

        if ($KB.HotFixID -eq "KB4015550") {
            $HotFixInstalled = "Pass"
            $HotFix = "KB4015550"
            $InstalledOn = $KB | ? {$_.HotFixID -eq "KB4015550"}
            $Check += 1
        }

        if ($KB.HotFixID -eq "KB4022715") {
            $HotFixInstalled = "Pass"
            $HotFix = "KB4022715"
            $InstalledOn = $KB | ? {$_.HotFixID -eq "KB4022715"}
            $Check += 1
        }

        if ($KB.HotFixID -eq "KB4019472") {
            $HotFixInstalled = "Pass"
            $HotFix = "KB4019472"
            $InstalledOn = $KB | ? {$_.HotFixID -eq "KB4019472"}
            $Check += 1
        }

        if ($Check.Count -eq 0) {
            $HotFixInstalled = "Fail"
            $HotFix = " "
            $InstalledOn = " "
        }

        $DNSName = Get-WmiObject Win32_Computersystem -ComputerName $Computer -Credential $Credential | Select-Object -ExpandProperty Name

        $AuditReport = New-Object System.Object
        $AuditReport | Add-Member -Type NoteProperty -Name Server -Value $Computer
        $AuditReport | Add-Member -Type NoteProperty -Name Name -Value $DNSName
        $AuditReport | Add-Member -Type NoteProperty -Name Connection -Value $Connected
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixInstalled -Value $HotFixInstalled
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixID -Value $HotFix
        $AuditReport | Add-Member -Type NoteProperty -Name InstalledOn -Value $InstalledOn.InstalledOn
        $AuditReport

    } else {

        $Connected = "Unable to connect"

        $AuditReport = New-Object System.Object
        $AuditReport | Add-Member -Type NoteProperty -Name Server -Value $Computer
        $AuditReport | Add-Member -Type NoteProperty -Name Name -Value " "
        $AuditReport | Add-Member -Type NoteProperty -Name Connection -Value $Connected
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixInstalled -Value " "
        $AuditReport | Add-Member -Type NoteProperty -Name HotFixID -Value " "
        $AuditReport | Add-Member -Type NoteProperty -Name InstalledOn -Value " "
        $AuditReport

    }
}

$Computers = Get-Content "C:\users\aowens\desktop\hospitals.txt"
$Throttle = 100
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
 
$Results | ConvertTo-Html -Head $HTMLHead -body $HTMLBody | Out-File "C:\Temp\MS_Patch_Hospitals.htm"
$Results | Export-CSV -Path "C:\Temp\MS_Patch_Hospitals.csv" -Force

$RunspacePool.Close()
$RunspacePool.Dispose()