function Convert-CertBase64 {
param(
    $Path
)
    [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($Path))
}