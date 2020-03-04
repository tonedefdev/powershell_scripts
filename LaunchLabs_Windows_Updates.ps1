$WindowsUpdatePath ="HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$AutoUpdate = "HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
$WSUS = "https://ewsus.alexandrialaunchlabs.com:8531"

Set-ItemProperty -Path $AutoUpdate -Name UseWUServer -Value 1 -Verbose -Force
Set-ItemProperty -Path $AutoUpdate -Name NoAutoUpdate -Value 0 -Verbose -Force
Set-ItemProperty -Path $AutoUpdate -Name DetectionFrequencyEnabled -Value 1 -Verbose -Force
Set-ItemProperty -Path $AutoUpdate -Name DetectionFrequency -Value 10 -Verbose -Force
Set-ItemProperty -Path $AutoUpdate -Name AutoInstallMinorUpdates -Value 1 -Verbose -Force
Set-ItemProperty -Path $AutoUpdate -Name AuPowerMangement -Value 1 -Verbose -Force
Set-ItemProperty -Path $AutoUpdate -Name AUOptions -Value 3 -Verbose -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name WUServer -Value $WSUS -Verbose -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name WUStatusServer -Value $WSUS -Verbose -Force