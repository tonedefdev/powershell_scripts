$Computer = $env:CLIENTNAME

$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('currentuser', $Computer)
$RegKey= $Reg.OpenSubKey('Software\Microsoft\Windows NT\CurrentVersion\Windows')
$DefaultPrinter = $RegKey.GetValue("Device")

$Default = Write-Output $DefaultPrinter | ConvertFrom-Csv -Header Name, Provider, Order | Select-Object -ExpandProperty Name | Format-Table -Property @{Name="Default Printer Name";Expression={$_.Name}} -AutoSize

$Default 