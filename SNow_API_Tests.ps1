function Get-SNOWDate {
param(
    [Parameter()]
    [Int]
    $SubtractDay
)
    
    $Hour =  (Get-Date).Hour

        if ($Hour -lt 10) {
            $Hour = ("0" + $Hour)
        }
    
    $Minute = (Get-Date).Minute
            
        if ($Minute -lt 10) {
            $Minute = ("0" + $Minute)
        }

    $Seconds = (Get-Date).Second

        if ($Seconds -lt 10) {
            $Seconds = ("0" + $Seconds)
        }
    
    $Year = (Get-Date).Year

    $Month = (Get-Date).Month
    
        if ($Month -lt 10) {
            $Month = ("0" + $Month)
        }
    
    if ([bool]$SubtractDay) {
        $Day = (Get-Date)
        $Day = $Day.AddDays("-" + $SubtractDay)
        if ($SubtractDay -ge 365) {
            $Year = $Day.AddYears(-1)
        }
        $Month = $Day.Month
            if ($Month -lt 10) {
                $Month = ("0" + $Month)
            }
        $Day = $Day.Day
            if ($Day -lt 10) {
                $Day = ("0" + $Day)
            }
        } else {
        $Day = (Get-Date).Day
            if ($Day -lt 10) {
                $Day = ("0" + $Day)
            }
        }

$SNOWDate = "'" + $Year.Year + "-" + $Month + "-" + $Day + "'" + "," + "'" + $Hour + ":" + $Minute + ":" + $Seconds + "'"
$SNOWDate
} 

$user = "aowens"
$pass = ""

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')

$Today = Get-SNOWDate
$BackDay = Get-SNOWDate -SubtractDay 1

# Specify endpoint uri
$uri = "https://aredev.service-now.com/api/now/table/u_user_access?sysparm_query=opened_atBETWEENjavascript:gs.dateGenerate($BackDay)@javascript:gs.dateGenerate($Today)"

# Specify HTTP method
$method = "GET"

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri 

# Print response
$Content = $response.Content | ConvertFrom-Json
$Content.result | ? {$_.u_state_task -eq "Open"}
