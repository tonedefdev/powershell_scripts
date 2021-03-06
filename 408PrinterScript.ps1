#This first line disables the script from prompting a window 
Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle,0)
#Sets the current default printer into a variable
$Default = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Default -eq $true} | Select-Object -ExpandProperty Name
#Builds a hashtable of all the printers 
$Printers = @("\\408PrintSrv\CVRCOffice_MFC","\\408PrintSrv\ERDoc_BW","\\408PrintSrv\EROffice1_MFC","\\408PrintSrv\EROffice2_Color","\\408PrintSrv\Front_BW","\\408PrintSrv\Lab_Color","\\408PrintSrv\Label_ERDoc","\\408PrintSrv\Label_Front","\\408PrintSrv\Label_MedOffice","\\408PrintSrv\Label_MedProc1","\\408PrintSrv\Label_MedProc2","\\408PrintSrv\Label_SxWork","\\408PrintSrv\Label_Treatment","\\408PrintSrv\MedOffice_MFC","\\408PrintSrv\MedProc_BW","\\408PrintSrv\MedRec_MFC","\\408PrintSrv\RICOH","\\408PrintSrv\SxOffice_Color","\\408PrintSrv\SxWork_BW","\\408PrintSrv\CorpUseOnly")
#Removes each printer from the array above. The ErrorAction supresses any errors from showing
Foreach ($Printer in $Printers) { Remove-Printer -Name $Printer -ErrorAction SilentlyContinue }
#Adds each printer from the array
Foreach ($Printer in $Printers) { Add-Printer -ConnectionName $Printer }
#Sets the default printer back to what it was originally
$wshNet = New-Object -ComObject WScript.Network
$wshNet.SetDefaultPrinter($Default)
