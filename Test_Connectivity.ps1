function Test-Connectivity {
    [CmdletBinding()]
    param (
            [Parameter(ValueFromPipeline)]
            $ComputerName
    )
    process {
        Write-Verbose -Message "Processing computer [$($ComputerName)]..."
        if ((Test-Connection -ComputerName $ComputerName -Quiet -Count 1) -and (Test-Path -Path "\\$ComputerName\C$")) {
            $true
        } else {
            $false
        }
    }
}