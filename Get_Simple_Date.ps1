function Get-Simple-Date {
    $day =  (Get-Date).Day

    $month = (Get-Date).Month

    $year = (Get-Date).Year

$date = "$month$day$year"
$date
} 