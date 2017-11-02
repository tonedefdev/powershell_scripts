$host.ui.rawui.WindowTitle = "Server Application Audit"

. "C:\PSScripts\Get_iLORemote.ps1"
. "C:\PSScripts\Get_NetFrameworkVersion_Function.ps1"
. "C:\PSScripts\Check_OpenDNS_Function.ps1"
. "C:\PSScripts\Get_Time_Function.ps1"

Function Add-HTMLTableAttribute
{
    Param
    (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $HTML,

        [Parameter(Mandatory=$true)]
        [string]
        $AttributeName,

        [Parameter(Mandatory=$true)]
        [string]
        $Value

    )

    $xml=[xml]$HTML
    $attr=$xml.CreateAttribute($AttributeName)
    $attr.Value=$Value
    $xml.table.Attributes.Append($attr) | Out-Null
    Return ($xml.OuterXML | out-string)
}

$timeStart = (Get-Time)

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
$cdc = "\\$adcomputer\D$\avimark_backup\ClientDataCollectionAVImarkExportAgent.exe"                                      

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
                                            $AuditReport | Add-Member -Type NoteProperty -Name CDCAgent -Value " "
                                            $ObjectHT += $AuditReport
                                            
                                            $Step = $Step + 1 
                                            
                                            Continue
                                        }
                                        
                                        elseif ((Test-Connection -Count 1 -ComputerName $adcomputer -Quiet -ErrorAction SilentlyContinue) -eq $true) {
                                        
                                        $TestConnection = "Connected"  

                                        $Activity = "Running audit on $adcomputer"
                                            
                                        Write-Progress -Activity $Activity -PercentComplete ($Step / $TotalSteps * 100)                                       
                                                  
                                        $Task = "iLO IP tests"                                                              

                                        Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)                                    
                                                                                                                                                                                                                                                     
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
                                        
                                        $Task = ".NET Framework version"                                                              

                                        Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)  
                                                                                
                                        $NetFrameWorkVersion = Get-NetFrameworkVersion -Computer $adcomputer

                                        $Task = "application checks"                                                              

                                        Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
                                                                                
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

                                        if ((Test-Path -Path $cdc -PathType Leaf) -eq $true) {
                                            $cdc = "Pass"
                                        }

                                        elseif ((Test-Path -Path $cdc -PathType Leaf) -eq $false) {
                                            $cdc = "Fail"
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
                                        $AuditReport | Add-Member -Type NoteProperty -Name CDCAgent -Value $cdc
                                        $ObjectHT += $AuditReport

                                        $Step = $Step + 1
                                                                                    
}

$timeEnd = (Get-Time)

$Step = $Step + 1
$Activity = "Exporting:"
$Task = "As CSV to 'C:\Temp\ServerAuditReport.csv'"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$ObjectHT | Select-Object ComputerName,Status,iLOIPAddress,iLOConnected,NetFrameworkVersion,KaseyaInstalled,WebrootInstalled,EvaultInstalled,CDCAgent | Export-Csv -Path "C:\Temp\ServerAuditReport.csv" -Force

$Step = $Step + 1
$Task = "As HTML to 'C:\Temp\ServerAuditReport.htm'"
Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$CSS = @'

<style>

body {

    background-color:#4CAF50;
    padding: 25px;
    
}

p, h1, h2, h3 {

    font-family: Calibri;
    text-align: center;
    
}

img {
    
    display: block;
    margin: 0 auto;
    
}

div.background {
    
        margin: 0 auto;
        padding: 45px;
        display: table;
        overflow: hidden;
        height: 1%;
        border-style: solid;
        border-color: white;
        background-color: white;
        border-radius: 15px;
        box-shadow: 2px 2px 15px 1px black; 
        -moz-box-shadow: 2px 2px 15px 1px black;
        
}

div.footer {
    
        padding: 25px;
        text-align: center;
        font-family: Calibri;
    
}

table.Log {
    
    margin: 0px auto; 
    border-width: 1px; 
    border-style: solid; 
    border-color: white; 
    border-collapse: collapse; 
    border-spacing: 0; 
    box-shadow: 5px 5px 5px #999; 
    -moz-box-shadow: 5px 5px 5px #999
    
}

.Log th {
    
    font-family: Calibri; 
    text-align: center; 
    border-width: 1px; 
    padding: 5px; 
    border-style: solid; 
    border-color: white; 
    border-bottom: 1px solid #ddd; 
    background-color: #4CAF50; 
    color: white
    
}
    
.Log th:first-child {border-radius: 6px 0 0 0;}
.Log th:last-child {border-radius: 0 6px 0 0;}
.Log th:only-child {border-radius: 6px 6px 0 0;}

.Log td {

    font-family: Calibri; 
    text-align: left; 
    border-width: 1px;
    padding: 5px;
    border-style: solid;
    border-color: white; 
    border-bottom: 1px solid #ddd
    
}

.Log tr:nth-child(even) {background-color: #f2f2f2}
.Log tr:hover {background-color:#A9A9A9}

</style>
'@

$NVALogo = "http://i.imgur.com/idZOZ2g.jpg"

$HTMLBody = "<div class='background'>"
$HTMLBody = $HTMLBody + "<img src=$NVALogo>"
$HTMLBody = $HTMLBody + "<H2>Weekly Server Audit Report</H2>"
$HTMLBody = $HTMLBody + "<p>Audit Started: <b>$timeStart</b> | Audit Completed: <b>$timeEnd</b></p>"
$HTMLBody = $HTMLBody + "</body>"

$HTMLFooter = "<div class='footer'>"
$HTMLFooter = $HTMLFooter + "<p>&copy 2017 National Veterinary Associates</p>"
$HTMLFooter = $HTMLFooter + "</div>"
$HTMLFooter = $HTMLFooter + "</div>"

$Report = $ObjectHT | ConvertTo-Html -Fragment | Out-String | Add-HTMLTableAttribute -AttributeName 'class' -Value 'Log'

ConvertTo-Html -Head $CSS -body ($HTMLBody + $Report + $HTMLFooter) | Out-File "C:\Temp\ServerAuditReport.htm" -Force

$Step = $Step + 1
$Activity = "Sending reports via e-mail"
Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$from = "helpdesk@nvanet.com"
$recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>", "Patrick Hong <phong@nvanet.com>")
$subject = "NVA Server Audit Report"
$SMTPServer = "nvaexch.nva.local"
$body = "See attached for weekly server audit report"
$attachments = @("C:\Temp\ServerAuditReport.csv", "C:\Temp\ServerAuditReport.htm")

if ($attachments -ne $null) {
    Send-MailMessage -From $from -To $recipients -Subject $subject -Body $body -Attachments $attachments -SmtpServer $SMTPServer 
}

$Task = "Server audit completed"

Write-Progress -Activity $Activity -Completed
