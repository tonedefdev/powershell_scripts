function New-FileNumber {
    $numbers = (0..9)
    $length = 5
    $fileNumber = "9"
    for ($i = 0; $i -lt $length; $i++)
    {
        $n = Get-Random $numbers
        $fileNumber += $n
    }
    return $fileNumber
}

function Format-PhoneNumber{
param(
    [string]$PhoneNumber
)
    $areaCode = "("
    for ($i = 0; $i -le 2; $i++)
    {
        $areaCode += $phoneNumber[$i]
    }

    $areaCode += ")"

    $prefix = " "
    for ($i = 3; $i -le 5; $i++)
    {
        $prefix += $phoneNumber[$i]
    }

    $end = "-"
    for ($i = 6; $i -le 9; $i++)
    {
        $end += $phoneNumber[$i]
    }

    return "$($areaCode)$($prefix)$($end)"
}

Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Choose the CSV for the Everbridge template"
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$directory = "FileSystem::\\are-reit\are\AREData\IS Dept\EverbridgeContacts"
$source = Get-FileName
$employees = Import-Csv -Path $source
$template = Import-CSV -Path "$directory\ContactTemplate_8.4_DO_NOT_DELETE.csv"
$headers = $template[0].PSObject.Properties.Name
$userFileNumber = Get-ChildItem -Path "$directory\ReadyForUpload" | ? {$_.Mode -ne "d-----"} | Sort-Object -Descending LastWriteTime | Select-Object -First 1
$fileNumberSource = $userFileNumber.VersionInfo.FileName
$externalIDs = Import-Csv -Path $fileNumberSource

$everbridgeTemplate = @()
foreach ($employee in $employees)
{

    if ($employee.'Work Contact: Work Mobile' -and $employee.'Work Contact: Work Mobile'.Trim() -notmatch "(\(\d\d\d\))+(\s\d\d\d)+(\-\d\d\d\d)")
    {
        $scrubbed = Format-PhoneNumber -PhoneNumber $employee.'Work Contact: Work Mobile'
        $employee.'Work Contact: Work Mobile' = $scrubbed
    }
    else 
    {
        $employee.'Work Contact: Work Mobile' = $employee.'Work Contact: Work Mobile'    
    }

    if ($employee.'Personal Cell' -and $employee.'Personal Cell'.Trim() -notmatch "(\(\d\d\d\))+(\s\d\d\d)+(\-\d\d\d\d)")
    {
        $scrubbed = Format-PhoneNumber -PhoneNumber $employee.'Personal Cell'
        $employee.'Personal Cell' = $scrubbed
    }
    else 
    {
        $employee.'Personal Cell' = $employee.'Personal Cell'
    }

    if ($employee.'Home Phone')
    {
        $homePhone = $employee.'Home Phone'
        $phoneCountry2 = "US"
    }
    else 
    {
        $homePhone = $null
        $phoneCountry2 = $null    
    }

    if ($employee.'Personal Cell')
    {
        $cellPhone = $employee.'Personal Cell'
        $phoneCountry1 = "US"
        $sms2Country = "US"
        $sms2 = $cellPhone
    }
    else 
    {
        $cellphone = $null
        $phoneCountry1 = $null
        $sms2Country = $null
        $sms2 = $null    
    }

    if ($employee.'Home Phone' -eq $employee.'Personal Cell')
    {
        $homePhone = $null
        $cellPhone = $employee.'Personal Cell'
        $sms1 = $null
        $sms2 = $cellPhone
        $phoneCountry1 = "US"
        $phoneCountry2 = $null
        $sms1Country = $null
        $sms2Country = "US"
    }

    if ($employee.'Work Contact: Work Mobile')
    {
        $workCell = $employee.'Work Contact: Work Mobile'
        $phoneCountry3 = "US"
        $sms1 = $employee.'Work Contact: Work Mobile'
        $sms1Country = "US"
    }
    else 
    {
        $workCell = $null
        $phoneCountry3 = $null
        $sms1 = $null
        $sms1Country = $null    
    }

    if ($employee.'Work Contact: Work Mobile' -eq $employee.'Personal Cell')
    {
        $workCell = $employee.'Work Contact: Work Mobile'
        $phoneCountry3 = "US"
        $sms1 = $employee.'Work Contact: Work Mobile'
        $sms1Country = "US"
        $cellphone = $null
        $phoneCountry1 = $null
        $sms2Country = $null
        $sms2 = $null    
    }

    if (-not $employee.'Personal Cell')
    {
        $cellPhone = $null
        $phoneCountry1 = $null
    }

    if (-not $sms2)
    {
        $sms2Country = $null
    }

    if (-not $sms1)
    {
        $sms1Country = $null
    }

    if (-not $workCell)
    {
        $phoneCountry3 = $null
    }

    if ($employee.Nickname)
    {
        $firstName = $employee.Nickname
    }
    else
    {
        $firstName = $employee.'First Name'
    }

    if (-not $employee.'File Number')
    {
        $id = ($externalIDs | ? {$_.'First Name' -eq $firstName -and $_.'Last Name' -eq $employee.'Last Name'}).'External ID'
        if ($id)
        {
            $fileNumber = $id
        } 
        else 
        {
            $fileNumber = New-FileNumber   
        } 
    } 
    else 
    {
        $fileNumber = $employee.'File Number'
    }

    $recordType = $null
    switch ($employee.'Business Unit Description')
    {
        'ARE' {$recordType = 'Employee'}
        'Agency Temp' {$recordType = 'Temporary'}
        'Consultants' {$recordType = 'Contractor'}
        'LFS II' {$recordType = 'Employee'}
    }

    $hash = [ordered]@{}

    for ($i = 0; $i -lt $headers.Count; $i++)
    {
        $key = $headers[$i]
        $value = $null
        switch ($key)
        {
            'First Name' {$value = $firstName}
            'Last Name' {$value = $employee.'Last Name'}
            'External ID' {$value = $fileNumber}
            'Country' {$value = 'US'}
            'Business Name' {$value = 'ARE'}
            'Record Type' {$value = $recordType}
            'Groups' {$value = $employee.'Groups'}
            'Location 1' {$value = 'Work'}
            'Location 2' {$value = 'Home'}
            'Street Address 2' {$value = $employee.'Address Line 1'}
            'Apt/Suite/Unit 2' {$value = $employee.'Address Line 2'}
            'City 2' {$value = $employee.City}
            'State/Province 2' {$value = $employee.'State/Province'}
            'Postal Code 2' {$value = $employee.'Zip/Postal Code'}
            'Country 2' {$value = 'US'}
            'Phone 1' {$value = $cellPhone}
            'Phone Country 1' {$value = $phoneCountry1}
            'Phone 2' {$value = $homePhone}
            'Phone Country 2' {$value = $phoneCountry2}
            'Phone 3' {$value = $workCell}
            'Phone Country 3' {$value = $phoneCountry3}
            'Email Address 1' {$value = $employee.'Work Contact: Work Email'}
            'Email Address 2' {$value = $employee.'Personal Contact: Personal Email'}
            'SMS 1' {$value = $sms1}
            'SMS 1 Country' {$value = $sms1Country}
            'SMS 2' {$value = $sms2}
            'SMS 2 Country' {$value = $sms2Country}
            'Custom Field 1' {$value = 'Region'}
            'Custom Value 1' {$value = $employee.'Location Description'}
            'Custom Field 2' {$value = 'Department'}
            'Custom Value 2' {$value = $employee.'Home Department Description'}
            'END' {$value = 'END'}
        }
        $hash.Add($key, $value)
    }
    $object = New-Object -TypeName PSObject -Property $hash
    $everbridgeTemplate += $object
}

$everbridgeTemplate | Export-Csv -Path "C:\Users\$env:USERNAME\OneDrive - ARE\Desktop\everbridgeimport.csv" -NoTypeInformation -Encoding UTF8