$filePath = "C:\Users\$env:username\Desktop"
$servers = Get-Content "$filePath\servers.txt"
$host.ui.rawui.WindowTitle = "Java Install Check & Clean Up Files"

foreach ($i in $servers)
{
$java = "\\$i\C$\Program Files (x86)\Java\jre1.8.0_111"
$config = "\\$i\C$\Temp\config.txt"
$javainstall = "\\$i\C$\Temp\jre-8u111-windows-i586.exe"
if (Test-Path -Path $java) {
Write-Host $i":" "Install was successful" -BackgroundColor DarkBlue
}
else {
Write-Host $i":" "Install was not successful, check server for error logs" -BackgroundColor Red
}
$javaprocess = Get-WmiObject Win32_Process -ComputerName $i
if ($javaprocess -like "jre-8u111-windows-i586.exe") {
    (Get-WmiObject Win32_Process -ComputerName $i | ?{ $_.ProcessName -like "jre1.8.0_111"}).Terminate()
    Write-Host $i ":" "Java process terminated" -BackgroundColor "DarkGreen"
}
elseif ($javaprocess -notlike "jre-8u111-windows-i586.exe") {
    Write-Host $i ":" "Java process not currently running" -BackgroundColor DarkYellow
}
}
Write-Host "Java check finished! Pressy any key to close script..." -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")