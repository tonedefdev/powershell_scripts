$ListService = Invoke-RestMethod -URI "https://nvashare.com/_vti_bin/ListData.svc/HospitalDirectory" -UseDefaultCredentials
$hospitals = $ListService.content.properties
$DomainsHT = @()

foreach ($hospital in $hospitals) {
                                    $URL = $hospital.HospitalWebsite -replace '(?:www\.)'
                                    
                                    $HospitalDomains = New-Object System.Object
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name HospitalNo -Value $hospital.HospitalNo
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name Hospital -Value $hospital.HospitalName                                          
                                    $HospitalDomains | Add-Member -Type NoteProperty -Name Website -Value $URL
                                    $DomainsHT += $HospitalDomains
}

$DomainsHT | Select-Object HospitalNo,Hospital,Website |Sort -Property HospitalNo | Export-Csv "C:\users\$env:username\desktop\nvawebsites.csv"
                              