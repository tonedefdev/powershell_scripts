function CSVHeaderCleaner {
[CmdletBinding()]
param(
    [string[]]$Path
)
$SourceFile = $Path
$SourceHeadersDirty = Get-Content -Path $SourceFile -First 2 | ConvertFrom-Csv
$SourceHeadersCleaned = $SourceHeadersDirty.PSObject.Properties.Name.Trim(' ') -replace '\s' , ''
$SourceData = Import-CSV -Path $SourceFile -Header $SourceHeadersCleaned | Select-Object -Skip 1
$SourceData | Export-Csv -Path "$Path" -Force
 
}
