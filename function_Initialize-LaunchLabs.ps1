function Initialize-LaunchLabs
{
[cmdletbinding()]
param(
    [string]$LogPath,
    [string]$SourceLocation,
    [string]$DotNetVersion,
    [string]$DestinationRoot
)
    Set-Location -Path $sourceLocation
    Write-Verbose "Running .NET clean command..."
    dotnet clean | Write-Output *>> $logPath
    Write-Verbose "Running .NET publish..."
    dotnet publish | Write-Output *>> $logPath

    $sourcePublish = "$sourceLocation\bin\debug\$DotNetVersion\publish"
    Set-Location -Path $sourcePublish
    $sourceFiles = Get-ChildItem -Path $sourcePublish -Recurse | ? {$_.Mode -eq "-a----"}
    $sourceDirectories = Get-ChildItem -Path $sourcePublish -Recurse | ? {$_.Mode -eq "d-----"}
    
    foreach ($directory in $sourceDirectories)
    {
        $source = $directory.FullName
        if ($source -ne $null)
        {
            $sourceSplit = $source.Split("\")
            $sourceSplitCount = $sourceSplit.Count
            $destinationBuild = ""
            for ($i = 8; $i -lt $sourceSplitCount; $i++)
            {
                if ($i -ne ($sourceSplitCount -1))
                {
                    $destinationBuild += "$($sourceSplit[$i])\"
                } else {
                    $destinationBuild += "$($sourceSplit[$i])"
                }
            }

            $destination = "$($destinationRoot)\$($destinationBuild)"
            $testPath = [bool](Test-Path -Path $destination -ErrorAction Ignore)
            if (-not($testPath))
            {
                New-Item -Path $destination -ItemType Directory -Force -Verbose *>> $logPath
            }
        }
    }
    
    foreach ($file in $sourceFiles) 
    {
        $source = $file.VersionInfo.FileName
        if ($source -ne $null)
        {
            $sourceSplit = $source.Split("\")
            $sourceSplitCount = $sourceSplit.Count
            $destinationBuild = ""
            for ($i = 8; $i -lt $sourceSplitCount; $i++)
            {
                if ($i -ne ($sourceSplitCount -1))
                {
                    $destinationBuild += "$($sourceSplit[$i])\"
                } else {
                    $destinationBuild += "$($sourceSplit[$i])"
                }
            }

            $destination = "$($destinationRoot)\$($destinationBuild)"
            $testPath = [bool](Test-Path -Path $destination -ErrorAction Ignore)
            if ($testPath)
            {
                $checkHash = Compare-FileHashes -SourcePath $source -DestinationPath $destination -ErrorAction SilentlyContinue
                if ($checkHash -eq $false)
                {
                    Remove-Item -Path $destination -Force -Verbose *>> $logPath
                    Copy-Item -Path $source -Destination $destination -Force -Verbose *>> $logPath
                }
            } else {
                Copy-Item -Path $source -Destination $destination -Force -Verbose *>> $logPath
            }
        }
    }
}