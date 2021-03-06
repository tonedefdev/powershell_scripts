Clear-Host
Import-Module ActiveDirectory
$currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
$PDC = Get-ADDomain | Select-Object -ExpandProperty PDCEmulator
$host.ui.rawui.WindowTitle = "Unlock_Reset_Password"
Do
    { 	  
        $accountLocked = Read-Host "Is the account locked out? [Y/N]"    
        if ($accountLocked -eq "Y") 
        {
            Write-Host "Searching for any locked accounts in the directory" -Background Magenta                               
                            $lockedUser = Search-ADAccount -Server $PDC -LockedOut | Select-Object -ExpandProperty LockedOut
                            if ($lockedUser -eq $true)
                                    {
                                        Search-ADAccount -Server $PDC -LockedOut | Format-List Name,LockedOut,SamAccountName,LastLogonDate,PasswordExpired,PasswordNeverExpires
                                        $identity = Read-Host "Enter the SamAccountName of the locked out account or choose [C] to continue"
                                             if ($identity -eq "C")
					                {& $currentPath\Unlock_Reset_Password.ps1}
			                     if ($identity -ne "")
                                                        {
                                                            try
                                                                {
                                                                    Unlock-ADAccount -Server $PDC -Identity $identity -Confirm
                                                                }
                                                            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                                                                {
                                                                    Write-Host $identity":" " The username could not be found, please enter a valid username and try again." -Background Red ;
                                                                    $invalidUser = Read-Host "Enter [Y] to continue, or [E] to exit"
                                                                    if ($invalidUser -eq "Y") {& $currentPath\Unlock_Reset_Password.ps1}
                                                                    elseif ($invalidUser -eq "E") {Exit}
                                                                }
                                                            catch [Microsoft.ActiveDirectory.Management.ADException]
                                                                {
                                                                Write-Host "You must run this script with elevated privileges!!!" -Background Red ; 
                                                                $exitCMD = Read-Host "Enter [C] to close out of current session"
                                                                if ($exitCMD -eq "C") {Exit}
                                                                }
                                                        }                                                      
                                    }                                                 
                                        
                                            if ($lockedUser -ne $true)
                                                {
                                                    Write-Host "No locked users currently found" -Background DarkGreen                        
                                                }
        }        
            if ($accountLocked -eq "N" -or $lockedUser -ne $true)
                {
            $username = Read-Host "Enter the username of the user"
            if ($username -ne "")
                {
       
                    try
                        {
                    "`n"
                    Write-Host "Searching for user: $username" -Background Magenta
                    Get-ADUser -Server $PDC -Identity $username -Properties Description -ErrorAction Stop  | Format-List Name,Description,Enabled,DistinguishedName                            
                        }
                    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                        {
                            Write-Host $username":" " The username could not be found, please enter a valid username and try again." -Background Red ;
                            $invalidUser = Read-Host "Enter [Y] to continue, or [E] to exit"
                            if ($invalidUser -eq "Y") {& $currentPath\Unlock_Reset_Password.ps1}
                            elseif ($invalidUser -eq "E") {Exit}
                        }
                    $confirm = Read-Host "Do you wish to change the password? [Y/N]"
                    if ($confirm -eq "Y")           
                                {
                                    try
                                        {
                                            Set-ADAccountPassword -Server $PDC -Identity $username -Reset -NewPassword (Read-Host "Enter new password" -AsSecureString) -Confirm  -ErrorAction Stop ; Write-Host "Password has been successfully reset!" -BackgroundColor Blue
                                        }
                                    catch [Microsoft.ActiveDirectory.Management.ADPasswordComplexityException]
                                        {
                                            Write-Host "The password does not meet the length, complexity, or history required of the domain" -Background Red ;
                                            $compError = Read-Host "To try again enter [R] or choose [X] to exit"
                                            if ($compError -eq "R")
                                            {    
                                                Do
                                                    {  
                                                        try
                                                            {                                                                                                                   
                                                                Set-ADAccountPassword -Server $PDC -Identity $username -Reset -NewPassword (Read-Host "Enter new password" -AsSecureString) -Confirm  -ErrorAction Stop ; 
                                                                $Success = Write-Host "Password has been successfully reset!" -BackgroundColor Blue
                                                                $Success ; Pause | & $currentPath\CORP_Reset_User_Password.ps1
                                                            }
                                                        catch [Microsoft.ActiveDirectory.Management.ADPasswordComplexityException]
                                                            {
                                                                Write-Host "The password does not meet the length, complexity, or history required of the domain" -Background Red ;
                                                                $compError = Read-Host "To try again enter [R] or choose [X] to exit"
                                                if ($compError -eq "X") 
                                                	{Exit}      
                                                            }
                                                    }    
                                                While ($Error[0]-ne "Microsoft.ActiveDirectory.Management.ADPasswordComplexityException")    
                                             
                                            }                                                                                                                                                                     
                                        }
                                }
                    if ($confirm -eq "N")
                        {
                            & $currentPath\Unlock_Reset_Password.ps1
                        } 
                                    
                }
               }
    }
While ($username -ne "")