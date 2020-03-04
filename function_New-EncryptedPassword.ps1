function New-EncryptedPassword {
param(
    [string]
    $Path,

    [string]
    $FileName
)
    $Login = Get-Credential
    $Pass = $Login.GetNetworkCredential().Password | ConvertTo-SecureString -AsPlainText -Force
    $Pass | ConvertFrom-SecureString | Set-Content -Path ($Path + "\" + $FileName + ".txt")
}