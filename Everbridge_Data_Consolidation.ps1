$source = "C:\users\aowens\desktop\Everbridge Emergency Report 040419.csv"
$everbridgeSource = Import-Csv "C:\users\aowens\desktop\a1afde15-cff1-40d4-9fb1-72b2f85cdc74.csv"
$employees = Import-Csv -Path $source
$everbridgeTemplate = @()
foreach ($employee in $employees)
{
    $processed = $false
    foreach ($record in $everbridgeSource)
    {
        if ($employee.'File Number' -eq $record.'External ID')
        {
            if ($employee.Nickname)
            {
                $firstName = $employee.Nickname
            }
            else
            {
                $firstname = $employee.'First Name'
            }

            $hash = [ordered]@{
                'First Name' = $firstName
                'Middle Initial' = $record.'Middle Initial'
                'Last Name' = $employee.'Last Name'
                'Suffix' = ''
                'External ID' = $employee.'File Number'
                'Country' = 'US'
                'Business Name' = "ARE"
                'Record Type' = $record.'Record Type'
                'Groups' = $record.Groups
                'SSO User ID' = ''
                'Travel Arranger' = ''
                'Location 1' = 'Work'
                'Street Address 1' = $record.'Street Address 1'
                'Apt/Suite/Unit 1' = ''
                'City 1' = $record.'City 1'
                'State/Province 1' = $record.'State/Province 1'
                'Postal Code 1' = $record.'Postal Code 1'
                'Country 1' = $record.'Country 1'
                'Latitude 1' = $record.'Latitude 1'
                'Longitude 1' = $record.'Longitude 1'
                'Location Id 1' = ''
                'Location 2' = 'Home'
                'Street Address 2' = $employee.'Address Line 1'
                'Apt/Suite/Unit 2' = $employee.'Address Line 2'
                'City 2' = $employee.City
                'State/Province 2' = $employee.'State/Province'
                'Postal Code 2' = $employee.'Zip/Postal Code'
                'Country 2' = "US"
                'Longitude 2' = ''
                'Location Id 2' = ''
                'Location 3' = ''
                'Street Address 3' = ''
                'Apt/Suite/Unit 3' = ''
                'City 3' = ''
                'State/Province 3' = ''
                'Postal Code 3' = ''
                'Country 3' = ''
                'Latitude 3' = ''
                'Longitude 3' = ''
                'Location Id 3' = ''
                'Location 4' = ''
                'Street Address 4' = ''
                'Apt/Suite/Unit 4' = ''
                'City 4' = ''
                'State/Province 4' = ''
                'Postal Code 4' = ''
                'Country 4' = ''
                'Latitude 4' = ''
                'Longitude 4' = ''
                'Location Id 4' = ''
                'Location 5' = ''
                'Street Address 5' = ''
                'Apt/Suite/Unit 5' = ''
                'City 5' = ''
                'State/Province 5' = ''
                'Postal Code 5' = ''
                'Country 5' = ''
                'Latitude 5' = ''
                'Longitude 5' = ''
                'Location Id 5' = ''
                'Extension Phone 1' = ''
                'Extension 1' = ''
                'Extension Phone Country 1' = ''
                'Extension Phone 2' = ''
                'Extension 2' = ''
                'Extension Phone Country 2' = ''
                'Extension Phone 3' = ''
                'Extension 3' = ''
                'Extension Phone Country 3' = ''
                'Extension Phone 4' = ''
                'Extension 4' = ''
                'Extension Phone Country 4' = ''
                'Extension Phone 5' = ''
                'Extension 5' = ''
                'Extension Phone Country 5' = ''
                'Phone 1' = $employee.'Home Phone'
                'Phone Country 1' = 'US'
                'Phone 2' = $employee.'Personal Cell'
                'Phone Country 2' = 'US'
                'Phone 3' = ''
                'Phone Country 3' = ''
                'Phone 4' = ''
                'Phone Country 4' = ''
                'Phone 5' = ''
                'Phone Country 5' = ''
                'Phone 6' = ''
                'Phone Country 6' = ''
                'Email Address 1' = $employee.'Work Contact: Work Email'
                'Email Address 2' = $employee.'Personal Contact: Personal Email'
                'Email Address 3' = ''
                'Email Address 4' = ''
                'Email Address 5' = ''
                'Plain Text Email - 1 way' = ''
                'Plain Text - 1 way Pager Service' = ''
                'Plain Text Email - 2 way' = ''
                'SMS 1' = ''
                'SMS 1 Country' = ''
                'SMS 2' = ''
                'SMS 2 Country' = ''
                'SMS 3' = ''
                'SMS 3 Country' = ''
                'SMS 4' = ''
                'SMS 4 Country' = ''
                'SMS 5' = ''
                'SMS 5 Country' = ''
                'FAX 1' = ''
                'FAX Country 1' = ''
                'FAX 2' = ''
                'FAX Country 2' = ''
                'FAX 3' = ''
                'FAX Country 3' = ''
                "TTY 1" = ''
                "TTY Country 1" = ''
                "TTY 2" = ''
                "TTY Country 2" = ''
                "TTY 3" = ''
                "TTY Country 3" = ''
                'Numeric Pager' = ''
                'Numeric Pager Country' = ''
                'Numeric Pager Pin' = ''
                'Numeric Pager Service' = ''
                'TAP Pager' = ''
                'TAP Pager Country' = ''
                'TAP Pager Pin' = ''
                'One Way SMS' = ''
                'One Way SMS Country' = ''
                'Custom Field 1' = 'Region'
                'Custom Value 1' = $employee.'Location Description'
                'Custom Field 2' = 'Department'
                'Custom Value 2' = $employee.'Home Department Description'
                'END' = 'END'
            }
            $object = New-Object -TypeName PSObject -Property $hash
            $everbridgeTemplate += $object
            $processed = $true
            Continue
        }
    }

    if (-not $processed)
    {
        if ($employee.Nickname)
        {
            $firstName = $employee.Nickname
        }
        else
        {
            $firstname = $employee.'First Name'
        }

        $recordType = ''
        switch ($employee.'Business Unit Description')
        {
            'ARE' {$recordType = 'Employee'}
            'Agency Temp' {$recordType = 'Temporary'}
            'Consultants' {$recordType = 'Contractor'}
            'LFS II' {$recordType = 'Employee'}
        }

        $hash = [ordered]@{
            'First Name' = $firstName
            'Middle Initial' = ''
            'Last Name' = $employee.'Last Name'
            'Suffix' = ''
            'External ID' = $employee.'File Number'
            'Country' = 'US'
            'Business Name' = "ARE"
            'Record Type' = $recordType
            'Groups' = ''
            'SSO User ID' = ''
            'Travel Arranger' = ''
            'Location 1' = 'Work'
            'Street Address 1' = ''
            'Apt/Suite/Unit 1' = ''
            'City 1' = ''
            'State/Province 1' = ''
            'Postal Code 1' = ''
            'Country 1' = ''
            'Latitude 1' = ''
            'Longitude 1' = ''
            'Location Id 1' = ''
            'Location 2' = 'Home'
            'Street Address 2' = $employee.'Address Line 1'
            'Apt/Suite/Unit 2' = $employee.'Address Line 2'
            'City 2' = $employee.City
            'State/Province 2' = $employee.'State/Province'
            'Postal Code 2' = $employee.'Zip/Postal Code'
            'Country 2' = "US"
            'Longitude 2' = ''
            'Location Id 2' = ''
            'Location 3' = ''
            'Street Address 3' = ''
            'Apt/Suite/Unit 3' = ''
            'City 3' = ''
            'State/Province 3' = ''
            'Postal Code 3' = ''
            'Country 3' = ''
            'Latitude 3' = ''
            'Longitude 3' = ''
            'Location Id 3' = ''
            'Location 4' = ''
            'Street Address 4' = ''
            'Apt/Suite/Unit 4' = ''
            'City 4' = ''
            'State/Province 4' = ''
            'Postal Code 4' = ''
            'Country 4' = ''
            'Latitude 4' = ''
            'Longitude 4' = ''
            'Location Id 4' = ''
            'Location 5' = ''
            'Street Address 5' = ''
            'Apt/Suite/Unit 5' = ''
            'City 5' = ''
            'State/Province 5' = ''
            'Postal Code 5' = ''
            'Country 5' = ''
            'Latitude 5' = ''
            'Longitude 5' = ''
            'Location Id 5' = ''
            'Extension Phone 1' = ''
            'Extension 1' = ''
            'Extension Phone Country 1' = ''
            'Extension Phone 2' = ''
            'Extension 2' = ''
            'Extension Phone Country 2' = ''
            'Extension Phone 3' = ''
            'Extension 3' = ''
            'Extension Phone Country 3' = ''
            'Extension Phone 4' = ''
            'Extension 4' = ''
            'Extension Phone Country 4' = ''
            'Extension Phone 5' = ''
            'Extension 5' = ''
            'Extension Phone Country 5' = ''
            'Phone 1' = $employee.'Home Phone'
            'Phone Country 1' = 'US'
            'Phone 2' = $employee.'Personal Cell'
            'Phone Country 2' = 'US'
            'Phone 3' = ''
            'Phone Country 3' = ''
            'Phone 4' = ''
            'Phone Country 4' = ''
            'Phone 5' = ''
            'Phone Country 5' = ''
            'Phone 6' = ''
            'Phone Country 6' = ''
            'Email Address 1' = $employee.'Work Contact: Work Email'
            'Email Address 2' = $employee.'Personal Contact: Personal Email'
            'Email Address 3' = ''
            'Email Address 4' = ''
            'Email Address 5' = ''
            'Plain Text Email - 1 way' = ''
            'Plain Text - 1 way Pager Service' = ''
            'Plain Text Email - 2 way' = ''
            'SMS 1' = ''
            'SMS 1 Country' = ''
            'SMS 2' = ''
            'SMS 2 Country' = ''
            'SMS 3' = ''
            'SMS 3 Country' = ''
            'SMS 4' = ''
            'SMS 4 Country' = ''
            'SMS 5' = ''
            'SMS 5 Country' = ''
            'FAX 1' = ''
            'FAX Country 1' = ''
            'FAX 2' = ''
            'FAX Country 2' = ''
            'FAX 3' = ''
            'FAX Country 3' = ''
            "TTY 1" = ''
            "TTY Country 1" = ''
            "TTY 2" = ''
            "TTY Country 2" = ''
            "TTY 3" = ''
            "TTY Country 3" = ''
            'Numeric Pager' = ''
            'Numeric Pager Country' = ''
            'Numeric Pager Pin' = ''
            'Numeric Pager Service' = ''
            'TAP Pager' = ''
            'TAP Pager Country' = ''
            'TAP Pager Pin' = ''
            'One Way SMS' = ''
            'One Way SMS Country' = ''
            'Custom Field 1' = 'Region'
            'Custom Value 1' = $employee.'Location Description'
            'Custom Field 2' = 'Department'
            'Custom Value 2' = $employee.'Home Department Description'
            'END' = 'END'
        }
        $object = New-Object -TypeName PSObject -Property $hash
        $everbridgeTemplate += $object
    }
}

$everbridgeTemplate | Export-Csv -Path "C:\users\aowens\desktop\everbridge\ContactTemplate_8.4.csv" -NoTypeInformation