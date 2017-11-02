$ListService = Invoke-RestMethod -URI "https://nvashare.com/_vti_bin/ListData.svc/HospitalDirectory" -UseDefaultCredentials
$Hospitals = $ListService.Content.Properties
$DomainsHT = @()

foreach ($hospital in $hospitals) {
                                    $Hours = $hospital.HoursOfOperation -replace '<div class=.ExternalClass......................................'
                                    $Hours = $Hours -replace '<.p.'
                                    $Hours = $Hours -replace '<.div.'
                                    $Hours = $Hours -replace '<.span.'
                                    $Hours = $Hours -replace 'n>'
                                    $Hours = $Hours -replace '<p>'

                                    $URL = $hospital.HospitalWebsite -replace '(?:www\.)'
                                    
                                    $HospitalDomains = New-Object System.Object
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name HospitalNo -Value $hospital.HospitalNo
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name Hospital -Value $hospital.HospitalName
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name Timezone -Value $hospital.TZ                                           
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name HoursOfOperation -Value $Hours
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name Website -Value  $URL
                                    $DomainsHT += $HospitalDomains
}

$DomainsHT | Select-Object HospitalNo,Hospital,HoursOfOperation | Sort -Property HospitalNo | Export-Csv "C:\users\$env:username\desktop\nvahours.csv"