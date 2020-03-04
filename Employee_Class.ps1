Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(
	Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(
    Mandatory=$True)]
    [string]
    $Message,
    
    [Parameter(
    ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
    [string]
    $Variable,

    [Parameter(
	Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
    [string]
    $Path
    )

    $Stamp = (Get-Date).toString("MM/dd/yyyy HH:mm:ss")
    $Line = "$Stamp $Level - $Variable : $Message"
    if ($Path) {
        Add-Content $Path -Value $Line
    } else {
        Write-Output $Line
    }
}

Function Get-ServiceNowRecord {
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

Function Update-ServiceNowRecord {
param(
    [string]
    $User,

    [string]
    $Pass,

    [string]
    $SysID,

    [string]
    $SamAccountName,

    [string]
    $WorkNote
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
        "work_notes" = $WorkNote;
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

Class Employee
{
    [string]
    $EmploymentStatus

    [string]
    $FirstName

    [string]
    $LastName

    [string]
    $PreferredName

    [string]
    $Title

    [string]
    $Office

    [string]
    $TelephoneNumber

    [string]
    $MobileNumber

    [string]
    $EmailAccount

    [string]
    $StreetAddress

    [string]
    $City

    [string]
    $State

    [string]
    $ZipCode

    [string]
    $Department

    [string]
    $Company

    [string]
    $Manager

    [string]
    $User

    [string]
    $Pass

    [string]
    $SysID

    [void] CreateUser()
    {
        $Child = ""
        $DC = ""
        $Server = ""
        $Path = ""
        $UPN = ""
        $Groups = ""
        $HomeDirectory = ""
        $Dir = ""
        $ADSupervisor = ""
        $LogDir = "C:\SNOWAutomation"
        $LogPathCreation = $LogDir + "\UserAccountCreation.log"

        if (!(Test-Path -Path $LogDir))
        {
            New-Item -Path $LogDir -ItemType Directory -Force
            New-Item -Path $LogPathCreation -ItemType File -Force
        }

        switch ($this.Office)
        {
            "Pasadena" {$Dir = "PAS"}
            "Maryland" {$Dir = "MD"}
            "San Francisco" {$Dir = "MB"}
            "Greater Boston" {$Dir = "MA"}
            "New York City" {$Dir = "NY"}
            "Research Triangle Park" {$Dir = "RTP"}
            "San Diego" {$Dir = "SD"}
            "Seattle" {$Dir = "SEA"}
        }

        switch ($this.EmploymentStatus) 
        {

            "LFS II-Permanent"
            {
                $Child = "buildingsupport"
                $DC = "labspace"
                $Server ="buildingsupport.labspace.com"
                $Path = "OU=$($this.Office),OU=Engineers,DC=$Child,DC=$DC,DC=com"
                $UPN = "buildingsupport.labspace.com"
                $HomeDirectory = "\\BLDG-SUP\ENG\Eng User"
            }
            
            "ARE-Permanent"
            {
                $DC = "labspace"
                $Server = "labspace.com"
                $Path = "OU=$($this.Office),OU=ARE Employees,DC=$DC,DC=com"
                $UPN = "are.com"
                $Groups = @(
                    "ARE $($this.Office)",
                    "J-Public",
                    "CorporateSecAwareness",
                    "PII Training",
                    "PhishingTraining",
                    "Ergonomics Training",
                    "ARE Employee Handbook"
                )
                $HomeDirectory = "\\ARE-REIT\ARE\$Dir User"
                $ADSupervisor = "CN=$($this.Manager),$Path"
            }

            "ARE-Temporary"
            {
                $DC = "labspace"
                $Server = "labspace.com"
                $Path = "OU=$($this.Office),OU=ARE Employees,DC=$DC,DC=com"
                $UPN = "are.com"
                $Groups = @(
                    "ARE $($this.Office)",
                    "J-Public",
                    "CorporateSecAwareness",
                    "PII Training",
                    "PhishingTraining",
                    "Ergonomics Training"
                )
                $HomeDirectory = "\\ARE-REIT\ARE\$Dir "
                $ADSupervisor = "CN=$($this.Manager),$Path"
            }
            
            "Non-ARE Temporary"
            {

            }

            "Consulatant/Contractor"
            {

            }

        }
        
        $Preferred = $this.PreferredName -split " "
        $Username = $Preferred[0] -split ""
        $SamAccountName = "$($Username[1].ToLower()) $($this.LastName.ToLower())"
        $Password = ""
        
        $Message = "Attempting to create employeee user account with username '$SamAccountName'"
        Write-Log -Level INFO -Message $Message -Path $LogPathCreation

        try
        {
            New-ADUser -Server $Server `
            -Name "$($this.FirstName) $($this.LastName)" `
            -GivenName $this.FirstName `
            -Surname $this.LastName `
            -DisplayName "$($Preferred[0]) $($this.LastName)" `
            -Title $this.Title `
            -Description $this.Title `
            -Office $this.Office `
            -Path $Path `
            -OfficePhone $this.TelephoneNumber `
            -MobilePhone $this.MobileNumber `
            -StreetAddress $this.StreetAddress `
            -City $this.City `
            -State $this.State `
            -PostalCode $this.ZipCode `
            -Department $this.Department `
            -Company $this.Company `
            -Manager $ADSupervisor `
            -SamAccountName $SamAccountName `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -UserPrincipalName "$SamAccountName@$UPN" `
            -HomeDrive "I:" `
            -HomeDirectory "$HomeDirectory\$SamAccountName" `
            -ErrorAction Stop

            while ([bool](!(Get-ADUser -Server $Server -Identity $SamAccountName)))
            { 
                Start-Sleep -Seconds 1
            }

            if ($this.EmploymentStatus -ne "LFS II-Permanent") 
            {
                Set-ADUser -Server $Server -Identity $SamAccountName -Add @{extensionAttribute2="$SamAccountName"}
            }

            if ($null -ne $Groups) 
            {
                foreach ($Group in $Groups) 
                {
                    Get-ADGroup -Server $Server -Identity $Group | Add-ADGroupMember -Server $Server -Members $SamAccountName
                }
            }

            $Message = "Successfully created user '$SamAccountName' for employee $($this.FirstName) $($this.LastName)"
            Write-Log -Level INFO -Message $Message -Path $LogPathCreation
            Update-ServiceNowRecord -User $this.User -Pass $this.Pass -SysID $this.SysID -SamAccountName $SamAccountName -WorkNote $Message
        }

        catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException]
        {
            Write-Log -Level INFO -Message "The username $SamAccountName was already taken. Attemping new username" -Path $LogPathCreation
            $Preferred = $this.PreferredName -split " "
            $Username = $Preferred[0] -split ""
            $SamAccountName = "$($Username[1].ToLower()).$($this.LastName.ToLower())"

            try
            {
                New-ADUser -Server $Server `
                -Name "$($this.FirstName) $($this.LastName)" `
                -GivenName $this.FirstName `
                -Surname $this.LastName `
                -DisplayName "$($Preferred[0]) $($this.LastName)" `
                -Title $this.Title `
                -Description $this.Title `
                -Office $this.Office `
                -Path $Path `
                -OfficePhone $this.TelephoneNumber `
                -MobilePhone $this.MobileNumber `
                -StreetAddress $this.StreetAddress `
                -City $this.City `
                -State $this.State `
                -PostalCode $this.ZipCode `
                -Department $this.Department `
                -Company $this.Company `
                -Manager $ADSupervisor `
                -SamAccountName $SamAccountName `
                -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) `
                -Enabled $true `
                -ChangePasswordAtLogon $true `
                -UserPrincipalName "$SamAccountName@$UPN" `
                -HomeDrive "I:" `
                -HomeDirectory "$HomeDirectory\$SamAccountName" `
                -ErrorAction Stop

                while ([bool]((Get-ADUser -Server $Server -Identity $SamAccountName) -eq $false))
                { 
                    Start-Sleep -Seconds 1
                }

                if ($this.EmploymentStatus -ne "LFS II-Permanent") 
                {
                    Set-ADUser -Server $Server -Identity $SamAccountName -Add @{extensionAttribute2="$SamAccountName"}
                }

                if ($null -ne $Groups) 
                {
                    foreach ($Group in $Groups) 
                    {
                        Get-ADGroup -Server $Server -Identity $Group | Add-ADGroupMember -Server $Server -Members $SamAccountName 
                    }
                }

                $Message = "Successfully created user '$SamAccountName' for employee $($this.FirstName) $($this.LastName)"
                Write-Log -Level INFO -Message $Message -Path $LogPathCreation
                Update-ServiceNowRecord -User $this.User -Pass $this.Pass -SysID $this.SysID -SamAccountName $SamAccountName -WorkNote $Message
            }

            catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException]
            {
                $Message = "An account already exists with both $($Username[1].ToLower()) $($this.LastName.ToLower()) and $($Username[1].ToLower()).$($this.LastName.ToLower()). Manual creation is required"
                Write-Log -Level ERROR -Message $Message -Path $LogPathCreation
                Update-ServiceNowRecord -User $this.User -Pass $this.Pass -SysID $this.SysID -WorkNote $Message
            }
        }

        catch [System.Exception]
        {
            $Message = "$($Error[0]) A general error occured. User account creation halted."
            Write-Log -Level ERROR -Message $Message -Path $LogPathCreation
        }
    }

    [void] CreateEmail()
    {
        $LogDir = "C:\SNOWAutomation"
        $LogPathCreation = $LogDir + "\UserAccountCreation.log"

        if (!(Test-Path -Path $LogDir))
        {
            New-Item -Path $LogDir -ItemType Directory -Force
            New-Item -Path $LogPathCreation -ItemType File -Force
        }
        
        if ($this.EmploymentStatus -eq "LFS II-Permanent")
        {
            $Server = "buildingsupport.labspace.com"
            $DC = "TXBDC01." + $Server
        } else {
            $Server = "labspace.com"
            $DC = "TX-AD01." + $Server
        }

        $Preferred = $this.PreferredName -split " "
        $EDB = Get-MailboxDatabase | ? {$_.ReplicationType -eq "Remote"} | Select-Object -ExpandProperty Name

        try 
        {
            $UserAccount = Get-ADUser -Server $Server -Filter {Name -eq "$($this.FirstName) $($this.LastName)"} -ErrorAction Stop
            Enable-Mailbox -Identity $UserAccount.SamAccountName `
            -DisplayName "$($Preferred[0]) $($this.LastName)" `
            -Database (Get-Random -InputObject $EDB) `
            -DomainController $DC `
            -PrimarySMTPAddress "$($UserAccount.SamAccountName)@$($this.EmailAccount)"

            while ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $false}))
            {
                Start-Sleep -Seconds 1
            }

            if ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $true}))
            {
                $Message = "Mailbox successfully enabled for $($this.FirstName) $($this.LastName) with email address $($UserAccount.SamAccountName)@$($this.EmailAccount)"
                Write-Log -Level INFO -Message $Message -Path $LogPathCreation
                Update-ServiceNowRecord -User $this.User -Pass $this.Pass -SysID $this.SysID -WorkNote $Message
            }
        }

        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            try
            {
                $Message = "Unable to find an employee by the name of $($this.Firstname) $($this.LastName). Attempting to find employee by their preferred name."
                Write-Log -Level INFO -Message $Message -Path $LogPathCreation

                $Preferred = "$($this.PreferredName) $($this.LastName)" -split " "
                $Username = $Preferred[0] -split ""
                $SamAccountName = "$($Username[1].ToLower()) $($this.LastName.ToLower())"

                $UserAccount = Get-ADUser -Server $Server -Filter {DisplayName -eq "$($this.PreferredName) $($this.LastName)"} -ErrorAction Stop
                Enable-Mailbox -Identity $UserAccount.SamAccountName `
                -DisplayName "$($Preferred[0]) $($this.LastName)" `
                -Database (Get-Random -InputObject $EDB) `
                -DomainController $DC `
                -PrimarySMTPAddress "$($UserAccount.SamAccountName)@$($this.EmailAccount)"

                while ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $false}))
                {
                    Start-Sleep -Seconds 1
                }
    
                if ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $true}))
                {
                    $Message = "Mailbox successfully enabled for $($this.FirstName) $($this.LastName) with email address $($UserAccount.SamAccountName)@$($this.EmailAccount)"
                    Write-Log -Level INFO -Message $Message -Path $LogPathCreation
                    Update-ServiceNowRecord -User $this.User -Pass $this.Pass -SysID $this.SysID -WorkNote $Message
                }
            }

            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
            {
                try
                {
                    $Message = "Unable to find an employee by the name of $($this.PreferredName) $($this.LastName). Attempting to find employee by their username."
                    Write-Log -Level INFO -Message $Message -Path $LogPathCreation

                    $Preferred = "$($this.PreferredName) $($this.LastName)" -split " "
                    $Username = $Preferred[0] -split ""
                    $SamAccountName = "$($Username[1].ToLower()) $($this.LastName.ToLower())"

                    $UserAccount = Get-ADUser -Server $Server -Identity $SamAccountName -ErrorAction Stop
                    Enable-Mailbox -Identity $UserAccount.SamAccountName `
                    -DisplayName "$($Preferred[0]) $($this.LastName)" `
                    -Database (Get-Random -InputObject $EDB) `
                    -DomainController $DC `
                    -PrimarySMTPAddress "$($UserAccount.SamAccountName)@$($this.EmailAccount)"

                    while ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $false}))
                    {
                        Start-Sleep -Seconds 1
                    }
        
                    if ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $true}))
                    {
                        $Message = "Mailbox successfully enabled for $($this.FirstName) $($this.LastName) with email address $($UserAccount.SamAccountName)@$($this.EmailAccount)"
                        Write-Log -Level INFO -Message $Message -Path $LogPathCreation
                        Update-ServiceNowRecord -User $this.User -Pass $this.Pass -SysID $this.SysID -WorkNote $Message
                    }
                }

                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                {
                    try
                    {
                        $Preferred = "$($this.PreferredName) $($this.LastName)" -split " "
                        $Username = $Preferred[0] -split ""
                        $SamAccountName = "$($Username[1].ToLower()) $($this.LastName.ToLower())"

                        $Message = "Unable to find an employee by the typical naming convention: '$SamAccountName'. Attempting to find employee by the alternate standard."
                        Write-Log -Level INFO -Message $Message -Path $LogPathCreation

                        $Preferred = "$($this.PreferredName) $($this.LastName)" -split " "
                        $Username = $Preferred[0] -split ""
                        $SamAccountName = "$($Username[1].ToLower()).$($this.LastName.ToLower())"

                        $UserAccount= Get-ADUser -Server $Server -Identity $SamAccountName -ErrorAction Stop
                        Enable-Mailbox -Identity $UserAccount.SamAccountName `
                        -DisplayName "$($Preferred[0]) $($this.LastName)" `
                        -Database (Get-Random -InputObject $EDB) `
                        -DomainController $DC `
                        -PrimarySMTPAddress "$($UserAccount.SamAccountName)@$($this.EmailAccount)"

                        while ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $false}))
                        {
                            Start-Sleep -Seconds 1
                        }
            
                        if ([bool](Get-Mailbox -Identity $UserAccount.SamAccountName | ? {$_.IsMailboxEnabled -eq $true}))
                        {
                            $Message = "Mailbox successfully enabled for $($this.FirstName) $($this.LastName) with email address $($UserAccount.SamAccountName)@$($this.EmailAccount)"
                            Write-Log -Level INFO -Message $Message -Path $LogPathCreation
                            Update-ServiceNowRecord -User $this.User -Pass $this.Pass -SysID $this.SysID -WorkNote $Message
                        }
                    }

                    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                    {
                        $Message = "$($Error[2]) Fatal error - ending termination process"
                        Write-Log -Level ERROR -Message $Message -Path $LogPathCreation
                    }
                }
            }
        }

        catch [System.Exception]
        {
            $Message = "A general error occurred. $($Error[0])"
            Write-Log -Level ERROR -Message $Message -Path $LogPathCreation
        }
    }

    [void] TerminateUser()
    {
        $LogDir = "C:\SNOWAutomation"
        $LogPathTerm = $LogDir + "\Termination.log"
        $Date = Get-Date

        if (!(Test-Path -Path $LogPathTerm))
        {
            New-Item -Path $LogDir -ItemType Directory -Force
            New-Item -Path $LogPathTerm -ItemType File -Force
        }
        
        if ($this.EmploymentStatus -eq "LFS II-Permanent")
        {
            $Server ="buildingsupport.labspace.com"
        } else {
            $Server = "labspace.com"
        }

        if ($this.EmploymentStatus -eq "LFS II-Permanent")
        {
            $Child = "buildingsupport"
            $DC = "labspace"
            $TargetPath = "OU=xDisabled Users,DC=$Child,DC=$DC,DC=com"
        } else {
            $DC = "labspace"
            $TargetPath = "OU=90 Day Retention,OU=xDisabled Users,OU=Non_User_Accounts,DC=$DC,DC=com"
        }

        try
        {
            $UserAccount = Get-ADUser -Server $Server -Filter {Name -eq "$($this.FirstName) $($this.LastName)"} -ErrorAction Stop
            $Groups = $UserAccount | Get-ADPrincipalGroupMembership -Server $Server
            $UserAccount | Set-ADUser -Description "Delete 90 days after $($Date)"
            $UserAccount | Disable-ADAccount -Server $Server
            if(!($UserAccount.Enabled))
            {
                $Message = "The user account for $($this.FirstName) $($this.LastName) was disabled"
                Write-Log -Level INFO -Message $Message -Path $LogPathTerm
            }

            foreach ($Group in $Groups.Name)
            {
                if ($Group -eq "Domain Users")
                {
                    Continue
                } else {
                    Remove-ADPrincipalGroupMembership -Identity $UserAccount.SamAccountName -MemberOf $Group
                }
            }

            $UserAccount | Move-ADObject -Server $Server -TargetPath $TargetPath

        }

        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            $Message = "Unable to find an employee by the name of $($this.Firstname) $($this.LastName). Attempting to find employee by their username."
            Write-Log -Level INFO -Message $Message -Path $LogPathTerm

            $Preferred = "$($this.Firstname) $($this.LastName)" -split " "
            $Username = $Preferred[0] -split ""
            $SamAccountName = "$($Username[1].ToLower()) $($this.LastName.ToLower())"

            try 
            {
                $UserAccount = Get-ADUser -Server $Server -Identity $SamAccountName -ErrorAction Stop
                $Groups = $UserAccount | Get-ADPrincipalGroupMembership -Server $Server
                $UserAccount | Disable-ADAccount -Server $Server
                if(!($UserAccount.Enabled))
                {
                    $Message = "The user account for $($this.FirstName) $($this.LastName) was disabled"
                    Write-Log -Level INFO -Message $Message -Path $LogPathTerm
                }
                
                foreach ($Group in $Groups.Name)
                {
                    if ($Group -eq "Domain Users")
                    {
                        Continue
                    } else {
                        Remove-ADPrincipalGroupMembership -Identity $UserAccount.SamAccountName -MemberOf $Group
                    }
                }
    
                $UserAccount | Move-ADObject -Server $Server -TargetPath $TargetPath
            }

            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
            {
                $Message = "Unable to find an employee by the username $($SamAccountName). Attempting to find employee by alternate username standard."
                Write-Log -Level INFO -Message $Message -Path $LogPathTerm
    
                $Preferred = "$($this.Firstname) $($this.LastName)" -split " "
                $Username = $Preferred[0] -split ""
                $SamAccountName = "$($Username[1].ToLower()).$($this.LastName.ToLower())"

                try 
                {
                    $UserAccount = Get-ADUser -Server $Server -Identity $SamAccountName -ErrorAction Stop
                    $Groups = $UserAccount | Get-ADPrincipalGroupMembership -Server $Server
                    $UserAccount | Disable-ADAccount -Server $Server
                    if(!($UserAccount.Enabled))
                    {
                        $Message = "The user account for $($this.FirstName) $($this.LastName) was disabled"
                        Write-Log -Level INFO -Message $Message -Path $LogPathTerm
                    }
                    
                    foreach ($Group in $Groups.Name)
                    {
                        if ($Group -eq "Domain Users")
                        {
                            Continue
                        } else {
                            Remove-ADPrincipalGroupMembership -Identity $UserAccount.SamAccountName -MemberOf $Group
                        }
                    }
        
                    $UserAccount | Move-ADObject -Server $Server -TargetPath $TargetPath
                }

                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                {
                    $Message = "$($Error[2]) Fatal error - ending termination process"
                    Write-Log -Level ERROR -Message $Message -Path $LogPathTerm
                }
            }   
        }

        catch [System.Exception]
        {
            $Message = "A general error occurred. $($Error[0])"
            Write-Log -Level ERROR -Message $Message -Path $LogPathTerm
        }
    }
}