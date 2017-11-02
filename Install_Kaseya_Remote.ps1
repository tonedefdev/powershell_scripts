$host.ui.rawui.WindowTitle = "Install Kaseya Remotely"
. "C:\PSScripts\Get_BIOS_Serial_Function.ps1"
$Computers = @(
    "408FileServer.NVA.local",
    "408PowerClock.NVA.local",
    "408Profile1.NVA.local",
    "408SharedServer.NVA.local",
    "408SQL1.NVA.local"
)
$KaseyaAgent = "\\NVADC6\Users\Public\Downloads\KcsSetup.exe"
$KaseyaReportHT = @()

$TotalSteps = $Computers.Count * 6
$Step = 1
$Activity = "Running Kaseya Install Tasks:"

Write-Progress -Activity $Activity -PercentComplete ($Step / $TotalSteps * 100)  

foreach ($Computer in $Computers) {
$KaseyaInstall = "\\$Computer\C$\Temp\"

                                        $Task = "connection to $Computer"
                                        Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                        $Step = $Step + 1 

                                        if ((Test-Connection -ComputerName $Computer -Count 1 -Quiet) -ne $true) {

                                                $Task = "connection to $Computer failed"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100) 
                                                
                                                $Connection = "Unable to connect to machine"
                                                
                                                $KaseyaReport = New-Object System.Object
                                                $KaseyaReport | Add-Member -Type NoteProperty -Name Computer -Value $Computer
                                                $KaseyaReport | Add-Member -Type NoteProperty -Name Connection -Value $Connection
                                                $KaseyaReport | Add-Member -Type NoteProperty -Name KaseyaInstall -Value " "
                                                $KaseyaReport | Add-Member -Type NoteProperty -Name SerialNumber -Value " "
                                                $KaseyaReportHT += $KaseyaReport
                                                $Step = $Step + 1
                                                Continue
                                        } else {
                                                $Task = "connection to $Computer successful"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1                                           

                                                $Connection = "Connected"
                                            
                                            if ((Test-Path -Path $KaseyaInstall) -eq $false) {

                                                $Task = "creation of 'Temp' directory"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

                                                New-Item -Path "C:\Temp" -Force -ErrorAction SilentlyContinue
                                            }

                                            if ((Test-Path -Path $KaseyaInstall -PathType Leaf) -eq $false) {
                                                
                                                $Task = "file transfer to $Computer"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1 

                                                Copy-Item -Path $KaseyaAgent -Destination $KaseyaInstall -ErrorAction SilentlyContinue
                                            }

                                            if ((Test-Path -Path "$KaseyaInstall\KcsSetup.exe" -PathType Leaf) -eq $true) {

                                                $Task = "install of Kaseya on $Computer"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1 

                                                C:\PsTools\PsExec.exe \\$Computer -s "C:\Temp\KcsSetup.exe" /r /s
                                            }

                                            if ((Test-Path -Path "$KaseyaInstall\KcsSetup.exe" -PathType Leaf) -eq $true) {

                                                $Task = "cleanup of install files on $Computer"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1 

                                                Remove-Item -Path "$KaseyaInstall\KcsSetup.exe" -ErrorAction SilentlyContinue
                                                $Kaseya = "Installed"
                                            }

                                            $Task = "BIOS serial grab from $Computer"
                                            Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                            $Step = $Step + 1 

                                            $BIOS = Get-BIOS -Computer $Computer

                                            $KaseyaReport = New-Object System.Object
                                            $KaseyaReport | Add-Member -Type NoteProperty -Name Computer -Value $Computer
                                            $KaseyaReport | Add-Member -Type NoteProperty -Name Connection -Value $Connection
                                            $KaseyaReport | Add-Member -Type NoteProperty -Name KaseyaInstall -Value $Kaseya
                                            $KaseyaReport | Add-Member -Type NoteProperty -Name SerialNumber -Value $BIOS
                                            $KaseyaReportHT += $KaseyaReport                                           

                                        }
}

$KaseyaReportHT | Select-Object Computer,Connection,KaseyaInstall,SerialNumber | Export-Csv -Path "C:\Temp\KaseyaAgentFix.csv"
$KaseyaReportHT | Select-Object Computer,Connection,KaseyaInstall,SerialNumber | Out-GridView

Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")