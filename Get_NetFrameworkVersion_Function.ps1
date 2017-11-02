function Get-NetFrameworkVersion {
[CmdletBinding()]
param(
    [string[]]$Computer
)
$ScriptBlockToRun = {
    $NetRegKey = Get-Childitem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $Release = $NetRegKey.GetValue("Release")
    Switch ($Release) {
        378389 {$NetFrameworkVersion = "4.5"}
        378675 {$NetFrameworkVersion = "4.5.1"}
        378758 {$NetFrameworkVersion = "4.5.1"}
        379893 {$NetFrameworkVersion = "4.5.2"}
        393295 {$NetFrameworkVersion = "4.6"}
        393297 {$NetFrameworkVersion = "4.6"}
        394254 {$NetFrameworkVersion = "4.6.1"}
        394271 {$NetFrameworkVersion = "4.6.1"}
        394802 {$NetFrameworkVersion = "4.6.2"}
        394806 {$NetFrameworkVersion = "4.6.2"}
        Default {$NetFrameworkVersion = "Net Framework 4.5 or later is not installed."}
    }
    $ObjectHT = @{
        NETFrameworkVersion = $NetFrameworkVersion
    }
    $Object = New-Object PSObject -Property $ObjectHT 
    $Object | Select-Object -ExpandProperty NETFrameworkVersion | Format-List


}
    Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockToRun ;
        
}