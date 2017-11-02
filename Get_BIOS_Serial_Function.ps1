function Get-BIOS {
    [CmdletBinding()]
        Param(
            [Parameter(
            Mandatory=$True)]
            [String] $Computer
        )

    Get-WMIObject Win32_BIOS -ComputerName $Computer | Select-Object -ExpandProperty SerialNumber

}