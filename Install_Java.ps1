$filePath = "C:\Users\$env:username\Desktop"
$servers = Get-Content "$filePath\servers.txt"
$source = "\\NVADC6\Java\jre-8u111-windows-i586.exe"
$cfgsource = "\\NVADC6\Java\config.txt"
$host.ui.rawui.WindowTitle = "Java Installer"

foreach ($i in $servers) 
{
    $destination = "\\$i\C$\temp"
        if (!(Test-Path -Path $destination)) 
            {
                New-Item -Path $destination
            }
        else {
                Copy-Item -Path $source -Destination $destination ;
                Copy-Item -Path $cfgsource -Destination $destination
             }

    $javainstall = "$destination\jre-8u111-windows-i586.exe"
        
        if (Test-Path -Path $javainstall -PathType Leaf) 
            {
                Write-Host $i":" "Java installer copied successfully to target computer" -BackgroundColor DarkGreen
            }
        else 
            {
                Write-Host $i":" "Java installer did not copy successfully, installation will fail on specified target" -BackgroundColor Red
            }
    $config = "$destination\config.txt"
        
        if (Test-Path -Path $config -PathType Leaf) 
            {
                Write-Host $i":" "Java installer config copied successfully to target computer" -BackgroundColor DarkCyan
            }
        else 
            {
                Write-Host $i":" "Java installer config didn't copy over successfully, installation will proceed with default values" -BackgroundColor DarkYellow
            }

C:\PSTools\psexec.exe \\$i -s -d "C:\Temp\jre-8u111-windows-i586.exe" INSTALLCFG=C:\Temp\config.txt 
}
