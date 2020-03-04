Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "JSON (*.json)| *.json"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$open = Get-FileName "C:\"
$flows = Get-Content -Path $open | ConvertFrom-Json
$sortedFlows = $flows.src_address | Sort -Unique
$sortedFlows | foreach {$ping = Invoke-Expression -Command "ping -a $_"; $ping = $ping -split " "; Write-Host "$($_): $($ping[2])"}