$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\TCPIP6\Parameters"

New-ItemProperty -Path $RegPath -Name DisabledComponents -Value 255 -PropertyType DWORD -Verbose -Force

Read-Host "Anything"