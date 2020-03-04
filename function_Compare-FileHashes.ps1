function Compare-FileHashes {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [ValidateNotNullorEmpty()]
        [string]$DestinationPath
    )
    begin 
    {
        $sourceHash = Get-FileHash -Path $sourcePath -Algorithm SHA256
        $destHash = Get-FileHash -Path $destinationPath -Algorithm SHA256
    }
    process {
        if ($sourceHash.Hash -eq $destHash.Hash)
        {
            return $true
        } else {
            return $false
        }
    }
}