Import-CSV -Path "C:\users\admin.aowens\desktop\SEA\SEA1124.csv" | foreach {

    $IP = $_.IP
    $Subnetmask = $_.Subnetmask
    $Description = $_.VLAN
    $CIDR = ConvertSubnetmaskTo-CIDR -Subnetmask $Subnetmask
    $Token = 'X$Htyb$CQ0.5bZx_8Xd4Arn!'
    $MasterID = 342
    $SectionID = 10

    Create-PHPIPAM-Subnet -URL "ipam.are.com" -Token $Token -App "test" -Description $Description -isChild 1 -Subnet $IP -Mask $CIDR -MasterID $MasterID -SectionID $SectionID
}