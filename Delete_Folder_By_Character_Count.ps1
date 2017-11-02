Clear-Host
$host.ui.rawui.WindowTitle = "Folder Deletion By Character Count"
$currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path

Do {
    $DirectoryPath = Read-Host "Please enter the path to the directory that contains the items looking to be removed"
        if ($DirectoryPath -ne "") {
            try {
                $Merged = @()
                $DirectoryContent = Get-ChildItem -Path $DirectoryPath -ErrorAction Stop | Select-Object -ExpandProperty Name                

                foreach ($Folder in $DirectoryContent) {
                    $InitialCount = $Folder | Measure-Object -Character | Select-Object Characters
                    $Data = New-Object System.Object 
                    $Data | Add-Member -Type NoteProperty -Name Characters -Value $InitialCount.Characters
                    $Data | Add-Member -Type NoteProperty -Name Files -Value $Folder 
                    $Merged += $Data
                    }                                          
                                    
                    if ($DirectoryContent -ne "") {
                        "`n" 
                        Write-Host "Directory '$DirectoryPath' found!" -BackgroundColor DarkGreen 
                        "`n" 
                        $Merged | Select-Object Files,Characters | Sort-Object Characters | Out-GridView
                        Break
                    }              
                    
                 }                  
                 
            catch [System.Management.Automation.ItemNotFoundException]{
                "`n" ; Write-Host "Directory '$DirectoryPath' was not found, enter valid path, and try again" -BackgroundColor Red ; "`n"
            } 
       } 
}     
While ($Error[0] -ne "System.Management.Automation.ItemNotFoundException")

$Merged = $Null
$RemoveCount = Read-Host "Enter the character count of the files/folders you wish to remove"
"`n"
Foreach ($Folder in $DirectoryContent) {
    $Count = $Folder | Measure-Object -Character | Select-Object -ExpandProperty Characters
        if ($RemoveCount -eq $Count) {
            $Path = $DirectoryPath + "\" + $Folder
            Remove-Item -Path $Path -Recurse -WhatIf
        } 
}
"`n"
$Results = Read-Host "If you're happy with the 'What if' results, enter [D] to permanently delete, [X] to exit, or [S] to start over"
"`n"
    if ($Results -eq "D") {
            Foreach ($Folder in $DirectoryContent) {
            $Count = $Folder | Measure-Object -Character | Select-Object -ExpandProperty Characters
                if ($RemoveCount -eq $Count) {
                $Path = $DirectoryPath + "\" + $Folder
                Remove-Item -Path $Path -Verbose -Force -Recurse 
                }
            }
    }

    if ($Results -eq "X") {Exit}
    if ($Results -eq "S") {& "$currentPath\Delete_Folder_By_Character_Count.ps1"}
"`n"