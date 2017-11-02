. "C:\Users\aowens\Desktop\SQL Licensing Project\Get_FileCSV.ps1"

$host.ui.rawui.WindowTitle = "Open DNS Audit"

$Step = 1
$TotalSteps = 6
$Activity = "Running Open DNS Audit Tasks:" 
$Task = "Logging on to Open DNS"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$loginURL = "https://login.umbrella.com"
$ie = New-Object -ComObject InternetExplorer.Application
$ie.visible = $false
$ie.navigate($loginURL)
while ($ie.Busy -eq $true) {Start-Sleep -Seconds 1}

$userfield = "username"
$passwordfield = "password"
$submitbutton = "sign-in"
$username = "aowens@nvanet.com"
$password = "P00dle!!"

($ie.Document.getElementsByName($userfield) | Select -First 1).value= $username
($ie.Document.getElementsByName($passwordfield) | Select -First 1).value = $password
($ie.Document.DocumentElement.getElementsByClassName('btn btn-rounded btn-primary button-signin') | Select -First 1).click()
while ($ie.Busy -eq $true) {Start-Sleep -Seconds 1}

$Step = 2
$Task = "Navigating to Network Devices page"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$networks = "https://dashboard.umbrella.com/o/2567/#configuration/identities/networks"
$ie.navigate($networks)

while ($ie.Busy -eq $true) {Start-Sleep -Seconds 1}

$Step = 3
$Task = "Expanding Network Devices page to grab all devices"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$ie.Document.parentWindow.scroll(0,2000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,5000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,10000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,15000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,20000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,35000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,45000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,50000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,50000)
Start-Sleep -Seconds 3

$ie.Document.parentWindow.scroll(0,50000)
Start-Sleep -Seconds 3

$Step = 4
$Task = "Exporting all Network Device IP addresses"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

$IPlist = ($ie.Document.documentElement.getElementsByClassName('table-column font-size-small field-ipAddress column-ipAddress'))
$IPListSorted = $IPlist | Select -ExpandProperty outerText | Foreach {$_.Trim()} | Out-File "C:\Temp\OpenDNSIP.txt" -Append

$Step = 5
$Task = "Logging out of OpenDNS"

Write-Progress -Activity $Activity -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)

Start-Sleep -Seconds 2
($ie.Document.documentElement.getElementsByClassName('dpl-button dpl-button-tertiary account-popover-box-user-signout-button') | Select -First 1).click()
$ie.Quit()

$Step = 6
$Task = "Completed"

Write-Progress -Activity $Activity -CurrentOperation $Task -Completed

Write-Host "IP Address list has been compiled!" -ForegroundColor Green 

"`n"
Do { 
$File = Get-Filename 
}
while ($File -eq $null)

Write-Host "Running CSV header cleanup..." -ForegroundColor Yellow

"`n"

$SourceFile = $File
$SourceHeadersDirty = Get-Content -Path $SourceFile -First 2 | ConvertFrom-Csv
$SourceHeadersCleaned = $SourceHeadersDirty.PSObject.Properties.Name.Trim(' ') -replace '\s' , ''
$SourceData = Import-CSV -Path $SourceFile -Header $SourceHeadersCleaned | Select-Object -Skip 1

Write-Host "CSV headers have been cleaned!" -ForegroundColor Green

"`n"

Write-Host "Running checks now..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

"`n"

$OpenDNSQuery = Get-Content "C:\Temp\OpenDNSIP.txt"

$SourceData | foreach {
                            $publicip = $_.LastPublicIP
                            $hostname = $_.Hostname

                                if ($OpenDNSQuery -contains $publicip) {
                                                                          Write-Host $hostname -NoNewline
                                                                          Write-Host ": " -NoNewLine
                                                                          Write-Host "Pass" -ForegroundColor Green -NoNewline "`n"

                               }

                                elseif ($OpenDNSQuery -notcontains $publicip) {

                                                                                  Write-Host $hostname -NoNewline
                                                                                  Write-Host ": " -NoNewLine
                                                                                  Write-Host "Fail" -ForegroundColor Red -NoNewline "`n"

                               }
}

Remove-Item -Path "C:\Temp\OpenDNSIP.txt"

"`n"

Write-Host "Finished checks against Open DNS IP Addresses!" -ForegroundColor Yellow

"`n"

Write-Host "Press any key to end script" -ForegroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")