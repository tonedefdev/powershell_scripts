Import-Module MSOnline
Connect-MsolService
$csv = Import-Csv -Path "C:\users\admin.aowens\Desktop\buildingsupport.net - Batch 1.csv"

foreach ($user in $csv)
{
    try
    {
        Write-Host "Processing $($user.Name)" -ForegroundColor Cyan
        $check = Get-MsolUser -UserPrincipalName $user.PrimarySmtpAddress -ea Stop | Select -ExpandProperty Licenses
        if ($check.AccountSkuId -notcontains "arereit:SPE_F1" -and "arereit:EXCHANGESTANDARD")
        {
            Write-Host "Setting location and adding license for $($user.Name)" -ForegroundColor Yellow
            Set-MsolUser -UserPrincipalName $user.PrimarySmtpAddress -UsageLocation US -ea Stop
            Set-MsolUserLicense -UserPrincipalName $user.PrimarySmtpAddress -AddLicenses @("arereit:SPE_F1","arereit:EXCHANGESTANDARD") -ea Stop

            $userCheck = Get-MsolUser -UserPrincipalName $user.PrimarySmtpAddress -ea Stop | Select -ExpandProperty Licenses
            if ($userCheck.AccountSkuId -contains "arereit:SPE_F1")
            {
                Write-Host "Completed $($user.Name)" -ForegroundColor Green
            }
        } else {
            Write-Host "$($user.Name) has correct license" -ForegroundColor Green
        } 
    }

    catch
    {
        $errorCount = $error.Count
        for ($i = 0; $i -lt $errorCount; $i++)
        {
            Write-Host $error[$i] -ForegroundColor Red
        }
        
        $error.Clear()    
    }
}