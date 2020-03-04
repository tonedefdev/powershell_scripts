$api_call = Get-Credential "Service Now API_Call Password"
$welcome = Get-Credential "Default Welcome Password"

$api_call_pass = $api_call.GetNetworkCredential().Password
$welcome_pass = $welcome.GetNetworkCredential().Password

[Environment]::SetEnvironmentVariable("api_call", $api_call_pass, "User")
[Environment]::SetEnvironmentVariable("welcome", $welcome_pass, "User")