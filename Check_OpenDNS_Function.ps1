function Check-OpenDNS {
    [CmdletBinding()]
param(
    [string[]]$Computer
)
   $ScriptBlock = {
       $URL = "http://www.pandora.com"
       $ie = New-Object -ComObject InternetExplorer.Application
       $ie.visible = $false
       $ie.navigate($URL)
       while ($ie.Busy -eq $true) {Start-Sleep -Milliseconds 100}
       $ie.Application.LocationName
       $ie.Quit()
       }

Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock

}