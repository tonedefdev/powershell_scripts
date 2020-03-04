function Get-PHPIPAM-Token {
Param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $URL,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $App,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $User,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Password
)

    $Pair = "${User}:${Password}"
    $Bytes = [System.Text.Encoding]::ASCII.GetBytes($Pair)
    $Base64 = [System.Convert]::ToBase64String($Bytes)
    $BasicAuthValue = "Basic $Base64"
    $Headers = @{ Authorization = $BasicAuthValue }
    $URL = $URL + "/" + "api/" + $App + "/" + "user/"
    $Token = Invoke-WebRequest -Uri $URL -Method Post -ContentType "application/json" -Headers $Headers
    $Json = $Token.Content | ConvertFrom-Json
    $Json.Data
}

function Get-PHPIPAM-TokenExp { 
Param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $URL,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $App,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Token
)
    $URL = $URL + "/api/" + $App + "/user/"
    $Headers = @{ Token = ${Token} }
    Invoke-WebRequest -Uri $URL -Method Get -ContentType "application/json" -Headers $Headers
}

function Get-PHPIPAM-Subnets {
Param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $URL,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $App,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Token,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [Int]
    $SubnetID
)

    $URL = $URL + "/api/" + $App + "/subnets/" + $SubnetID + "/"
    $Headers = @{ Token = ${Token} }
    $Subnets = Invoke-WebRequest -Uri $URL -Method Get -ContentType "application/json" -Headers $Headers
    $Content = $Subnets.Content | ConvertFrom-Json
    $Content.data
}

function Get-PHPIPAM-Sections {
Param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $URL,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $App,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Token,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [Int]
    $SectionID
)

    $URL = $URL + "/api/" + $App + "/sections/"
    $Headers = @{ Token = ${Token} }
    $Sections = Invoke-WebRequest -Uri $URL -Method Get -ContentType "application/json" -Headers $Headers
    $Content = $Sections.Content | ConvertFrom-Json
    $Content.data
}

function New-PHPIPAMSection {
Param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $URL,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $App,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Token,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [Int]
    $SectionID,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [String]
    $SectionName
)

    $URL = $URL + "/api/" + $App + "/sections/"

    $Headers = @{ 
        Token = $Token 
    }

    $Body = @{
        id = $SectionID
        name = $SectionName
        showVLAN = 1
        showVRF = 1
    }

    Invoke-WebRequest -Uri $URL -Method POST -ContentType "application/json" -Headers $Headers -Body ($Body | ConvertTo-Json)
    
}

function New-PHPIPAMSubnet {
Param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $URL,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $App,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Token,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Description,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [Int]
    $isChild,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [String]
    $Subnet,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [Int]
    $Mask,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [Int]
    $isFolder,

    [Parameter(
    Mandatory=$False,
    ValueFromPipeline=$True)]
    [Int]
    $MasterID,

    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [Int]
    $SectionID
)

    
    $URL = $URL + "/api/" + $App + "/subnets/"

    $Headers = @{ 
        Token = $Token 
    }

    if ($isChild -eq 0) {
        $Body = @{
            subnet = $Subnet
            mask = $Mask
            sectionId = $SectionID
            description = $Description
            isFolder = $isFolder
            discoverSubnet = 1
            pingSubnet = 1
            scanAgent = 1
        }
    } else {
        $Body = @{
            subnet = $Subnet
            mask = $Mask
            sectionId = $SectionID
            masterSubnetId = $MasterID
            description = $Description
            isFolder = $isFolder
            discoverSubnet = 1
            pingSubnet = 1
            scanAgent = 1
        }
    }

    Invoke-WebRequest -Uri $URL -Method POST -ContentType "application/json" -Headers $Headers -Body ($Body | ConvertTo-Json)

}

function ConvertSubnetmaskTo-CIDR {
param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [String]
    $Subnetmask
)

    Switch($Subnetmask) {
        "255.255.255.252" {$CIDR = 30}
        "255.255.255.248" {$CIDR = 29}
        "255.255.255.240" {$CIDR = 28}
        "255.255.255.224" {$CIDR = 27}
        "255.255.255.192" {$CIDR = 26}
        "255.255.255.128" {$CIDR = 25}
        "255.255.255.0" {$CIDR = 24}
        "255.255.254.0" {$CIDR = 23}
        "255.255.252.0" {$CIDR = 22}
        "255.255.248.0" {$CIDR = 21}
        "255.255.240.0" {$CIDR = 20}
        "255.255.224.0" {$CIDR = 19}
        "255.255.192.0" {$CIDR = 18}
        "255.255.128.0" {$CIDR = 17}
        "255.255.0.0" {$CIDR = 16}
        "255.254.0.0" {$CIDR = 15}
        "255.252.0.0" {$CIDR = 14}
        "255.248.0.0" {$CIDR = 13}
        "255.240.0.0" {$CIDR = 12}
        "255.224.0.0" {$CIDR = 11}
        "255.192.0.0" {$CIDR = 10}
        "255.128.0.0" {$CIDR = 9}
        "255.0.0.0" {$CIDR = 8}
    }

    $CIDR
}

function ConvertCIDRTo-Subnetmask {
param(
    [Parameter(
    Mandatory=$True,
    ValueFromPipeline=$True)]
    [Int]
    $CIDR
)

    Switch($CIDR) {
        30 {$Subnetmask = "255.255.255.252"}
        29 {$Subnetmask = "255.255.255.248"}
        28 {$Subnetmask = "255.255.255.240"}
        27 {$Subnetmask = "255.255.255.224"}
        26 {$Subnetmask = "255.255.255.192"}
        25 {$Subnetmask = "255.255.255.128"}
        24 {$Subnetmask = "255.255.255.0"}
        23 {$Subnetmask = "255.255.254.0"}
        22 {$Subnetmask = "255.255.252.0"}
        21 {$Subnetmask = "255.255.248.0"}
        20 {$Subnetmask = "255.255.240.0"}
        19 {$Subnetmask = "255.255.224.0"}
        18 {$Subnetmask = "255.255.192.0"}
        17 {$Subnetmask = "255.255.128.0"}
        16 {$Subnetmask = "255.255.0.0"}
        15 {$Subnetmask = "255.254.0.0"}
        14 {$Subnetmask = "255.252.0.0"}
        13 {$Subnetmask = "255.248.0.0"}
        12 {$Subnetmask = "255.240.0.0"}
        11 {$Subnetmask = "255.224.0.0"}
        10 {$Subnetmask = "255.192.0.0"}
        9 {$Subnetmask = "255.128.0.0"}
        8 {$Subnetmask = "255.0.0.0"}
    }

    $Subnetmask
}