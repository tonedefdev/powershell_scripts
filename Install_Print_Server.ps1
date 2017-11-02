$filePath = "C:\Users\$env:username\Desktop"
$servers = Get-Content "$filePath\servers.txt"
$host.ui.rawui.WindowTitle = "Install Print Server"

foreach ($i in $servers) 
{
    Add-WindowsFeature Print-Server | Write-Host $i":" "Print services successfully installed." -BackgroundColor DarkBlue
}