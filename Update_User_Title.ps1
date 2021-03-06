Clear-Host
Import-Module ActiveDirectory
$gc = [system.directoryservices.activedirectory.forest]::GetCurrentForest().Name+':3268' 
$currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path 
do
    {
	Clear-Host
        "========================================"
        
        Write-Host "Type the word [EXIT] to quit at anytime " -BackgroundColor DarkGreen
        
        "========================================"
        "`n"
        $a = Read-Host ("`n" + "Enter the username of the employee")
        if ($a -ne "Exit") 
        {
            try 
                {
                    $getTitle = Get-ADUser -Identity $a -Properties Title | Select-Object -ExpandProperty Title
                    "`n" + "=============================================================================" + "`n" + "`n" ; Write-Host "Searching for:" $a -Background DarkGreen ; "`n"  + "`n" + "=============================================================================" ; "`n" + "`n" + "Current Title: " + $getTitle + "`n"
                }
                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                    {
                      Write-Host $a":" " The username could not be found, please enter a valid username and try again." -Background Red ;
                      $invalidUser = Read-Host "Enter [Y] to continue, or [E] to exit"
                      if ($invalidUser -eq "Y") {& $currentPath\Update_User_Title.ps1}
                      elseif ($invalidUser -eq "E") {Exit}
                    }
        }
        if ($getTitle -ne "") 
            {
                $title = Read-Host ("Enter the title you wish to add/modify")
            
        if ($title -ne "Exit") 
        {
           try 
                { 
                    Set-ADUser -Identity $a -Replace @{title=$title} -ErrorAction Stop ; Write-Host "Action completed successfully!" -Background Blue
                }
                catch [Microsoft.ActiveDirectory.Management.ADException]
                {
                    Write-Host "You must run this script with elevated privileges!!!" -Background Red ; 
                    $exitCMD = Read-Host "Enter [C] to close out of current session"
                    if ($exitCMD -eq "C") {Exit}
                }           
            }                     
   
            }
    }
while ($a -ne "Exit" -and $title -ne "Exit")