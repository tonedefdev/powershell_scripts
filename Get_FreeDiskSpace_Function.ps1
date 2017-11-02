Function Get-FreeDiskSpace($drive,$computer)
{
    $driveData = Get-WmiObject -Class Win32_LogicalDisk `
    -Computername $computer -Filter "Name = '$drive'"
"
    $computer free disk space on drive $drive
    $("{0:n2}" -f ($driveData.FreeSpace/1MB)) MegaBytes
"
} #end Get-FreeDiskSpace