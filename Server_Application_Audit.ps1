$host.ui.rawui.WindowTitle = "Server Application Audit"
. "C:\PSScripts\Get_iLORemote.ps1"
. "C:\PSScripts\Get_NetFrameworkVersion.ps1"

Import-Module ActiveDirectory 

$ADComputers = Get-ADComputer -Filter {(Enabled -eq $True)} -Properties OperatingSystem,DNSHostName | where {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*") -or ($_.OperatingSystem -like "*Windows Server 2016*")} | Sort DNSHostName | Select-Object -ExpandProperty DNSHostName

$TotalSteps = $ADComputers.Count + 4

$ObjectHT = @()

$Step = 1 
$Activity = "Running Server Application Audit Tasks:"

foreach ($adcomputer in $ADComputers) {

$kaseya = "\\$adcomputer\C$\Program Files (x86)\Kaseya"
$webroot = "\\$adcomputer\C$\Program Files (x86)\Webroot"
$webroot64 = "\\$adcomputer\C$\Program Files\Webroot"
$evault = "\\$adcomputer\C$\Program Files\EVault Software"                                      

                                        $Task = "Connecting to $adcomputer"

                                        Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)                                      

                                        if ((Test-Connection -Count 2 -ComputerName $adcomputer -Quiet -ErrorAction SilentlyContinue) -eq $false) {
                                            
                                            $Task = "Connection to server unavailable"
                                            
                                            Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

                                            $TestConnection = "Connection to server currently unavailable"

                                            $AuditReport = New-Object System.Object
                                            $AuditReport | Add-Member -Type NoteProperty -Name ComputerName -Value $adcomputer
                                            $AuditReport | Add-Member -Type NoteProperty -Name Status -Value $TestConnection                                            
                                            $AuditReport | Add-Member -Type NoteProperty -Name iLOIPAddress -Value " "
                                            $AuditReport | Add-Member -Type NoteProperty -Name iLOConnected -Value " "
                                            $AuditReport | Add-Member -Type NoteProperty -Name NetFrameworkVersion -Value " "
                                            $AuditReport | Add-Member -Type NoteProperty -Name KaseyaInstalled -Value " "
                                            $AuditReport | Add-Member -Type NoteProperty -Name WebRootInstalled -Value " "
                                            $AuditReport | Add-Member -Type NoteProperty -Name EvaultInstalled -Value " "
                                            $ObjectHT += $AuditReport
                                            
                                            $Step = $Step + 1 
                                            
                                            Continue
                                        }
                                        
                                        elseif ((Test-Connection -Count 1 -ComputerName $adcomputer -Quiet -ErrorAction SilentlyContinue) -eq $true) {

                                        $Task = "Running audit on $adcomputer"
                                            
                                        Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                        
                                        $TestConnection = "Connected"                                                                          
                                                                                                                   
                                        $iLOIPaddress = Get-iLORemote -Computer $adcomputer

                                        if ($iLOIPaddress.trim() -ne $null) {
                                            if ((Test-Connection -Count 2 -Computer $iLOIPaddress.trim() -Quiet -ErrorAction SilentlyContinue) -eq $true) {
                                            $iLOConnected = "Pass"
                                            }
                                            
                                            elseif ((Test-Connection -Count 2 -Computer $iLOIPAddress.trim() -Quiet -ErrorAction SilentlyContinue) -eq $false) {
                                            $iLOConnected = "Fail"
                                            }       

                                        }

                                        elseif ($iLOIPaddress.trim() -eq $null) {
                                            $iLOConnected = " "
                                        }                                                                                                                                                               
                                                                                
                                        $NetFrameWorkVersion = Get-NetFrameworkVersion -Computer $adcomputer
                                                                                
                                        if ((Test-Path -Path $kaseya) -eq $true) {
                                            $KaseyaInstalled = "Pass"
                                            
                                        }

                                        elseif ((Test-Path -Path $kaseya) -eq $false) {
                                            $KaseyaInstalled = "Fail"
                                            
                                        }

                                        if ((Test-Path $webroot,$webroot64) -eq $true -notlike $false) {
                                            $WebrootInstalled = "Pass"
                                            
                                        }

                                        elseif ((Test-Path $webroot,$webroot64) -eq $false -notlike $true) {
                                            $WebrootInstalled = "Fail"
                                            
                                        }

                                        if ((Test-Path -Path $evault ) -eq $true) {
                                            $EvaultInstalled = "Pass"
                                            
                                        }

                                        elseif ((Test-Path -Path $evault) -eq $false) {
                                            $EvaultInstalled = "Fail"
                                            
                                        }
                                        }

                                        $AuditReport = New-Object System.Object
                                        $AuditReport | Add-Member -Type NoteProperty -Name ComputerName -Value $adcomputer
                                        $AuditReport | Add-Member -Type NoteProperty -Name Status -Value $TestConnection
                                        $AuditReport | Add-Member -Type NoteProperty -Name iLOIPAddress -Value $iLOIPAddress
                                        $AuditReport | Add-Member -Type NoteProperty -Name iLOConnected -Value $iLOConnected
                                        $AuditReport | Add-Member -Type NoteProperty -Name NetFrameworkVersion -Value $NetFrameworkVersion.NetFrameWorkVersion
                                        $AuditReport | Add-Member -Type NoteProperty -Name KaseyaInstalled -Value $KaseyaInstalled
                                        $AuditReport | Add-Member -Type NoteProperty -Name WebRootInstalled -Value $WebrootInstalled
                                        $AuditReport | Add-Member -Type NoteProperty -Name EvaultInstalled -Value $EvaultInstalled
                                        $ObjectHT += $AuditReport

                                        $Step = $Step + 1
                                                                                    
}

$Step = $Step + 1
$Activity = "Exporting:"
$Task = "As CSV to 'C:\Temp\ServerAuditReport.csv'"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$ObjectHT | Select-Object ComputerName,Status,iLOIPAddress,iLOConnected,NetFrameworkVersion,KaseyaInstalled,WebrootInstalled,EvaultInstalled | Export-Csv -Path "C:\Temp\ServerAuditReport.csv"

$Step = $Step + 1
$Activity = "Exporting:"
$Task = "As HTML to 'C:\Temp\ServerAuditReport.htm'"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$HTMLHead = "<style>"
$HTMLHead = $HTMLHead + "BODY{background-color:white;}"
$HTMLHead = $HTMLHead + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$HTMLHead = $HTMLHead + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "</style>"

$NVALogo = "http://i.imgur.com/idZOZ2g.jpg"

$HTMLBody = "<body>"
$HTMLBody = $HTMLBody + "<img src=$NVALogo>"
$HTMLBody = $HTMLBody + "<H2>Weekly Server Audit Report</H2>"
$HTMLBody = $HTMLBody + "</body>"

$ObjectHT | ConvertTo-Html -Head $HTMLHead -body $HTMLBody | Out-File "C:\Temp\ServerAuditReport.htm"

$Step = $Step + 1 
$Task = "Sending report via e-mail"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$from = "helpdesk@nvanet.com"
$recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>")
$subject = "NVA Server Audit Report"
$SMTPServer = "nvaexch.nva.local"
$body = Get-Content "C:\Temp\ServerAuditReport.htm" | Out-String

if ($body -ne $null) {
    Send-MailMessage -From $from -To $recipients -Subject $subject -BodyAsHTML $body -Attachments "C:\Temp\ServerAuditReport.csv" -SmtpServer $SMTPServer 
}

$Task = "Server audit completed"

Write-Progress -Activity $Activity -Completed
