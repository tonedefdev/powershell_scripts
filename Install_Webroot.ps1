$host.ui.rawui.WindowTitle = "Install Webroot Remotely"
$Computers = @(
                "408App1.NVA.local",
                "408DC1.NVA.local",
                "408FileServer.NVA.local",
                "408PowerClock.NVA.local",
                "408PrintSrv.NVA.local",
                "408Profile1.NVA.local",
                "408Profile2.NVA.local",
                "408RDBroker.NVA.local",
                "408RDHost1.NVA.local",
                "408RDHost2.NVA.local",
                "408RDHost3.NVA.local",
                "408RDHost4.NVA.local",
                "408RDLicSQL.NVA.local",
                "408SharedServer.NVA.local",
                "408SoundApp1.NVA.local",
                "408SQL1.NVA.local",
                "408SQL2.NVA.local"
)
$WebrootAgent = "\\NVADC6\Users\Public\Downloads\wsasme.exe"
$WebrootReportHT = @()

$TotalSteps = ($Computers.Count * 6)
$Step = 1
$Activity = "Running Webroot Install Tasks:"

Write-Progress -Activity $Activity -PercentComplete ($Step / $TotalSteps * 100)  

foreach ($Computer in $Computers) {
$WebrootInstall = "\\$Computer\C$\Temp\"

                                        $Task = "connection to $Computer"
                                        Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                        $Step = $Step + 1 

                                        if ((Test-Connection -ComputerName $Computer -Count 1 -Quiet) -ne $true) {

                                                $Task = "connection to $Computer failed"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100) 
                                                
                                                $Connection = "Unable to connect to machine"
                                                
                                                $WebrootReport = New-Object System.Object
                                                $WebrootReport | Add-Member -Type NoteProperty -Name Computer -Value $Computer
                                                $WebrootReport | Add-Member -Type NoteProperty -Name Connection -Value $Connection
                                                $WebrootReport | Add-Member -Type NoteProperty -Name WebrootInstall -Value " "                                                
                                                $WebrootReportHT += $WebrootReport
                                                $Step = $Step + 1
                                                Continue
                                        }
                                        
                                        elseif ((Test-Connection -ComputerName $Computer -Count 1 -Quiet) -eq $true) {

                                                $Task = "connection to $Computer successful"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1                                           

                                                $Connection = "Connected"
                                            
                                            if ((Test-Path -Path $WebrootInstall) -eq $false) {

                                                $Task = "creation of 'Temp' directory"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

                                                New-Item -Path "C:\Temp" -Force -ErrorAction SilentlyContinue
                                            }

                                            if ((Test-Path -Path $WebrootInstall -PathType Leaf) -eq $false) {
                                                
                                                $Task = "file transfer to $Computer"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1 

                                                Copy-Item -Path $WebrootAgent -Destination $WebrootInstall -ErrorAction SilentlyContinue
                                            }

                                            if ((Test-Path -Path "$WebrootInstall\wsasme.exe" -PathType Leaf) -eq $true) {

                                                $Task = "install of Webroot on $Computer"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1 

                                                C:\PsTools\PsExec.exe \\$Computer -s "C:\Temp\wsasme.exe" /key=SAD7-ENTP-478B-9278-7335 /silent 
                                            }

                                            if ((Test-Path -Path "$WebrootInstall\wsasme.exe" -PathType Leaf) -eq $true) {

                                                $Task = "cleanup of install files on $Computer"
                                                Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                $Step = $Step + 1 

                                                Remove-Item -Path "$WebrootInstall\wsasme.exe" -ErrorAction SilentlyContinue
                                                $Webroot = "Installed"
                                            }

                                            $WebrootReport = New-Object System.Object
                                            $WebrootReport | Add-Member -Type NoteProperty -Name Computer -Value $Computer
                                            $WebrootReport | Add-Member -Type NoteProperty -Name Connection -Value $Connection
                                            $WebrootReport | Add-Member -Type NoteProperty -Name WebrootInstall -Value $Webroot
                                            $WebrootReportHT += $WebrootReport                                           

                                        }
}

Write-Progress -Activity $Activity -Completed

$WebrootReportHT | Select-Object Computer,Connection,WebrootInstall | Export-Csv -Path "C:\Temp\WebrootAgentFix.csv"
$WebrootReportHT | Select-Object Computer,Connection,WebrootInstall | Out-GridView

Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")