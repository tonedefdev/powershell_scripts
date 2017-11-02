Function Count-Characters {
       [CmdletBinding()]
    Param(
    [Parameter(
        Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True)]
        [string] $Path,

    [Parameter(
        Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True)]
        [string]$CSVPath    
    )
    Get-ChildItem -Path $Path -Filter * | Measure-Object -Character | Export-Csv $CSVPath
}