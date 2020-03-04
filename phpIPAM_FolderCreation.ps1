$Lists = Get-ChildItem -Path "C:\users\admin.aowens\Desktop\SEA"
$Lists = $Lists.Name
$URL = "ipam.are.com"

$Token = 'X$Htyb$CQ0.5bZx_8Xd4Arn!'

foreach ($List in $Lists) {
    $Path = "C:\users\admin.aowens\Desktop\SD\$List"
    $Description = $List -replace ".csv"
    $Section = 10  

    Create-PHPIPAM-Subnet -URL "ipam.are.com" -Token $Token -App "test" -Description $Description -isFolder 1 -SectionID $Section
}
            

