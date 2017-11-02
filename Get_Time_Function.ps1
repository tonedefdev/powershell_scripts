function Get-Time {
    $hour =  (Get-Date).Hour

            if ($hour -lt 10) {
                $hour = ("0" + (Get-Date).Hour)
            }
    
    $minute = (Get-Date).Minute
            
            if ($minute -lt 10) {
                $minute = ("0" + (Get-Date).Minute)
            }

    $seconds = (Get-Date).Second

            if ($seconds -lt 10) {
                $seconds = ("0" + (Get-Date).Second)
            }

$time = "$hour" + ":" + "$minute" + ":" + "$seconds"
$time
} 
