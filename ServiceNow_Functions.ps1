Function Get-ServiceNowRecord
{
param(
    [String]
    $User,

    [String]
    $Pass,

    [String]
    $UAT
)
    # Build auth header
    $Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User, $Pass)))

    # Set proper headers
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('Authorization',('Basic {0}' -f $Base64AuthInfo))
    $Headers.Add('Accept','application/json')

    # Specify endpoint uri
    $URI = "https://aredev.service-now.com/api/now/table/u_user_access_task?number=$UAT"

    # Specify HTTP method
    $Method = "GET"

    # Send HTTP request
    $Response = Invoke-WebRequest -Headers $Headers -Method $Method -Uri $URI

    # Print response
    if ($Response.StatusCode -eq 200)
    {
        $Content = $Response.Content | ConvertFrom-Json
        return $Content.result.sys_id
    }
}

Function Update-ServiceNowRecord
{
param(
    [String]
    $User,

    [String]
    $Pass,

    [String]
    $SysID,

    [String]
    $SamAccountName
)
    # Build auth header
    $Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User, $Pass)))

    # Set proper headers
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('Authorization',('Basic {0}' -f $Base64AuthInfo))
    $Headers.Add('Accept','application/json')

    # Specify endpoint uri
    $URI = "https://aredev.service-now.com/api/now/table/u_user_access_task/$SysID"
    
    # Specify request body
    
    $Params = @{
        "work_notes" ="Active Directory user and e-mail creation completed by automation routine";
        "u_ad_username_eng" = $SamAccountName;
    }

    # Specify HTTP method
    $Method = "PUT"

    # Send HTTP request
    $Response = Invoke-WebRequest -Headers $Headers -Body ($Params | ConvertTo-Json) -Method $Method -Uri $URI 

    # Print response
    if ($Response.StatusCode -eq 200)
    {
        return "Ticket successfully updated"
    }
}