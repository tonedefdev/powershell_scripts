function Compare-Conditions {
    [CmdletBinding()]
    param(
        $Message,
        $Condition1,
        $Condition2 
    )
    if ($Condition1 -eq $Condition2) 
    {
        Write-Host $Message -NoNewline 
        Write-Host "[ " -NoNewline
        Write-Host "OK" -NoNewline -ForegroundColor Green
        Write-Host " ]" -NoNewline
    
    } else {
        Write-Host $Message -NoNewline 
        Write-Host "[ " -NoNewline
        Write-Host "FAIL" -NoNewline -ForegroundColor Red
        Write-Host " ]" -NoNewline    
    }
}

enum algorithim {
    MACTripleDES
    MD5
    RIPEMD160
    SHA1
    SHA256
    SHA384
    SHA512
}

function Get-VerifiedHash {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [ValidateNotNullOrEmpty()]
        [algorithim]$Algorithim,
        [ValidateNotNullOrEmpty()]
        [string]$Hash
    )    
    process {
        $checkHash = Get-FileHash -Path $Path -Algorithm $Algorithim
        $Message = "Checksum validation results: "
        Compare-Conditions -Message $Message -Condition1 $checkHash.Hash -Condition2 $Hash
    }
}