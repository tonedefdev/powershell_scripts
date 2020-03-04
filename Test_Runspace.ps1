$SourcePath = "C:\Temp\Windows 10 1803"
$Source = Get-ChildItem -Path $SourcePath -Recurse
$SourceFiles = $Source | ? {$_.Mode -eq "-a----"}
$SourceDirectories = $Source | ? {$_.Mode -eq "d-----"} | Select-Object -ExpandProperty FullName | Sort
$CSV = "C:\Temp\MigrationSheet.csv"

foreach ($Directory in $SourceDirectories)
{
    $String = ""
    $Source = $Directory
    $Split = $Source.Split('\')
    $Count = $Split.Length - 1

    for ($i = 0; $i -lt $Count; $i++)
    {
        if($Split[$i] -eq "Temp")
        {
            $String += "Test\"   
        } else {
            $String += ($Split[$i] + "\")
        }
    }

    $Destination = "$($String)$($Split[$Count])"

    if (!(Test-Path -Path $Destination))
    {
        New-Item -Path $Destination -ItemType Directory -Force
    }
}


$Scriptblock = {
param(
    [object]$File,
    [string]$CSV,
    [string]$Drive
)
    $String = ""
    $Source = $File.VersionInfo.FileName
    $Split = $Source.Split('\')
    $Count = $Split.Length - 1

    for ($i = 0; $i -lt $Count; $i++)
    {
        if($Split[$i] -eq "Temp")
        {
            $String += "Test\"   
        } else {
            $String += ($Split[$i] + "\")
        }
    }

    $Destination = "$($String)$($Split[$Count])"

    if (!(Test-Path -Path $Destination))
    {
        $Syncing = $false
        Start-BitsTransfer -Priority Foreground -Source $Source -Destination $Destination
    } else {
        
        $Syncing = $false
        $FileCheck = Get-ChildItem -Path $Destination

        if ($File.Length -ne $FileCheck.Length)
        {
            $Syncing = $true
            Start-BitsTransfer -Priority Foreground -Source $Source -Destination $Destination
        }
    }

    $FileCheck = Get-ChildItem -Path $Destination

    if ($File.Length -eq $FileCheck.Length)
    {
        $TransferBytes = $true

        if ([bool](Test-Path -Path $Destination -ErrorAction Ignore))
        {
            $CompletionStatus = $true
        }
    } else {
        $TransferBytes = $false
        $CompletionStatus = $false
    }

    $Params = @{
        Source = $Source
        Destination = $Destination
        FileSync = $Syncing
        FileSizeMB = [math]::Round(($File.Length / 1MB),4)
        VerifiedBytes = $TransferBytes
        Completed = $CompletionStatus
    }

    $Result = New-Object -TypeName PSObject -Property $Params | Select Source,Destination,FileSync,FileSizeMB,VerifiedBytes,Completed | Export-CSV -Path $CSV -Append -NoTypeInformation
}

$Throttle = 64
$initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Throttle,$initialSessionState,$Host)
$RunspacePool.Open()
$Jobs = @()

foreach ($File in $SourceFiles)
{
    $Job = [powershell]::Create().AddScript($Scriptblock).AddArgument($File).AddArgument($CSV).AddArgument($Drive)
    $Job.RunspacePool = $RunspacePool
    $Jobs += New-Object PSObject -Property @{
        Pipe = $Job
        Result = $Job.BeginInvoke()
    }
}

$Results = @()

foreach ($Job in $Jobs){   
    
    $Results += $Job.Pipe.EndInvoke($Job.Result)

}