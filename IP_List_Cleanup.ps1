. "C:\users\$env:username\documents\phpIPAM_Functions.ps1"

$List = Read-Host "Enter name of list to be sorted"
$Export = $List + ".csv"
$List = $List + ".txt"


$IPs = Get-Content -Path "C:\users\$env:username\desktop\$List"
$IPs = $IPs -match "IP: \b(?:\d{1,3}\.){3}\d{1,3}\b"
$IPs = $IPs.Split(' ')
$IPs = $IPs -match "\b(?:\d{1,3}\.){3}\d{1,3}\b" | Get-Unique

$VLAN = Get-Content -Path "C:\users\$env:username\desktop\$List"
$VLAN = $VLAN -match "IP: \b(?:\d{1,3}\.){3}\d{1,3}\b"
$VLAN = $VLAN.Split(':')

$VLANS = @()

foreach ($Line in $VLAN) {
    
    if ($Line -match "N/A") {
        Continue
    }
    if ($Line -match "\b(?:\d{1,3}\.){3}\d{1,3}\b") {
        Continue
    } else {
        $VLANS += ($Line -replace "IP")
    }
}

$IPAddresses = @()
$Subnetmasks = @()

foreach ($IP in $IPs) {

    if ($IP -match "\b(?:\d{1,3}\.){3}\d{1,3}\/\d\d\b") {
        $Address = $IP.Split("/")
        $IPAddresses += $Address[0]
        $CIDR = ConvertCIDRTo-Subnetmask -CIDR $Address[1]
        $Subnetmasks += $CIDR
        Continue 
    }

    if ($IP -like "255.*") {
        $Subnetmasks += $IP
        Continue
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}1{1,3}\b") {
        Continue
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}21{1,3}\b") {
        Continue
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}129{1,3}\b") {
        Continue
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}160{1,3}\b") {
        $IPAddresses += $IP
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}0{1,3}\b") {
        $IPAddresses += $IP
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}32{1,3}\b") {
        $IPAddresses += $IP
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}64{1,3}\b") {
        $IPAddresses += $IP
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}96{1,3}\b") {
        $IPAddresses += $IP
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}128{1,3}\b") {
        $IPAddresses += $IP
    }

    if ($IP -match "\b(?:\d{1,3}\.){3}192{1,3}\b") {
        $IPAddresses += $IP
    }
}

$Sorted = @()

for ($i = 0; $i -lt $IPAddresses.Length; $i++) {
    $Hash = @{
        Subnetmask = $Subnetmasks[$i]
        IP = $IPAddresses[$i]
        VLAN = $VLANS[$i].trim()
    }
    $Object = New-Object PSObject -Property $Hash
    $Sorted += $Object
}

if ($Sorted -ne $null) {
    $Sorted | Select-Object IP,Subnetmask,VLAN | Export-Csv -Path "C:\users\$env:username\desktop\$Export" -NoTypeInformation
}
