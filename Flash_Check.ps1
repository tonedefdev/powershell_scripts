$computers = Get-Content "C:\Users\$env:username\desktop\servers.txt"
$path = "C:\Users\$env:username\desktop\failedflash.txt"

foreach ($i in $computers) {
$flash1 = "\\$i\C$\Windows\System32\Macromed\Flash\FlashUtil64_23_0_0_207_ActiveX.exe"
$flash2 = "\\$i\C$\Windows\System32\Macromed\Flash\FlashUtil64_23_0_0_205_ActiveX.exe"
if((Test-Path $flash1,$flash2) -eq $true -notlike $false) {
Write-Host $i ":" "Flash installed successfully" -Background DarkBlue
}
elseif((Test-Path $flash1,$flash2) -eq $false -notlike $true) {
Write-Host $i ":" "Flash did not install properly" -Background Red
}
}
Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")