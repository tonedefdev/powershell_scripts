$ScriptBlock = {
Param(
    $Computer
)
    if (([bool](Test-Connection -ComputerName $Computer -Count 2)))
    {

        $Connected = "Connected"
        
        $LocalAdmin = ([bool](Get-WmiObject -ComputerName $Computer Win32_Service -Property StartName | ? {$_.StartName -like "*Administrator*"}))

        $Properties = @{
            Connection = $Connected
            ComputerName = $Computer
            LocalAdminAsService = $LocalAdmin
        }

        $Object = New-Object -Type PSObject -Property $Properties
        $Object

    } else {

        $Connected = "Unable to connect"
        
        $Properties = @{
            Connection = $Connected
            ComputerName = $Computer
            LocalAdminAsService = ""
        }

        $Object = New-Object -Type PSObject -Property $Properties
        $Object
   }
}

$Computers = Get-ADComputer -Filter {(Enabled -eq $True)} -Properties OperatingSystem,DNSHostName | ? {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*") -or ($_.OperatingSystem -like "*Windows Server 2016*")} | Sort DNSHostName | Select-Object -ExpandProperty DNSHostName

$Throttle = 30
$initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Throttle,$initialSessionState,$Host)
$RunspacePool.Open()
$Jobs = @()

foreach ($Computer in $Computers)
{
   $Job = [powershell]::Create().AddScript($Scriptblock).AddArgument($Computer)
   $Job.RunspacePool = $RunspacePool
   $Jobs += New-Object PSObject -Property @{
      Pipe = $Job
      Result = $Job.BeginInvoke()
   }
}

$Results = @()
ForEach ($Job in $Jobs)
{   
    $Results += $Job.Pipe.EndInvoke($Job.Result)
}

$Results | Export-Csv "C:\users\$env:USERNAME\desktop\LocalAdminAsService.csv" -NoTypeInformation