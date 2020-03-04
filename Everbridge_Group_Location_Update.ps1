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

$everbridgeTemplate = @()
foreach ($employee in $employees)
{
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
            'First Name' {$value = $employee.'First Name'}
            'Last Name' {$value = $employee.'Last Name'}
            'External ID' {$value = $employee.'File Number'}
            'Record Type' {$value = $recordType}
            'Groups' {$value = $employee.'Location Description'}
            'END' {$value = 'END'}
        }
        $hash.Add($key, $value)
    }
    $object = New-Object -TypeName PSObject -Property $hash
    $everbridgeTemplate += $object
}

$everbridgeTemplate | Export-Csv -Path "C:\Users\$env:USERNAME\OneDrive - ARE\Desktop\everbridgeimport.csv" -NoTypeInformation -Encoding UTF8