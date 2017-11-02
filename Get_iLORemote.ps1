function Get-iLORemote {
[CmdletBinding()]
param(
    [string[]]$Computer
)

$iloipbat = "\\NVADC6\Users\Public\Downloads\iloip.bat"
$destination = "\\$Computer\C$\Temp"

if ((Test-Path -Path $destination) -eq $false) {

    New-Item -Path $destination -ItemType Directory

}

Copy-Item -Path $iloipbat -Destination $destination -Force -ErrorAction SilentlyContinue

$testpath = Test-Path -Path "$destination\iloip.bat" -PathType Leaf

if ($testpath -eq $true) {
   
    Invoke-Command -ComputerName $Computer -ScriptBlock { & "C:\Temp\iloip.bat" } | Out-Null

    $iloip = "\\$Computer\C$\iloip.txt"
    $iloinfo = "\\$Computer\C$\iloinfo.txt"
    Get-Content -Path $iloip
    Remove-Item -Path $iloip
    Remove-Item -Path $iloinfo
    Remove-Item -Path "$destination\iloip.bat"
}
}