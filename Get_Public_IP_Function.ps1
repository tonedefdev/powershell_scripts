function Get-PublicIP {
[CmdletBinding()]
param(
    [string[]]$Computer
)
   $ScriptBlock = {
       $URL = "http://myip.dnsomatic.com"
       $ie = New-Object -ComObject InternetExplorer.Application
       $ie.visible = $false
       $ie.navigate($URL)
       while ($ie.Busy -eq $true) {Start-Sleep -Seconds 1}
       ($ie.document.body.innerHTML).trim()
    }

Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock

}