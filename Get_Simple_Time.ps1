function Get-Simple-Time {
    $hour =  (Get-Date).Hour

    $minute = (Get-Date).Minute

$date = "$hour$minute"
$date
} 