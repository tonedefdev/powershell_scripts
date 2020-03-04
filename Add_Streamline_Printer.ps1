$check = [bool](Get-Printer -Name "\\hq-stream\RICOH Secure Print" -ea SilentlyContinue)

if (!$check)
{
    Add-Printer -ConnectionName "\\HQ-STREAM\RICOH Secure Print" -Confirm:$false
}